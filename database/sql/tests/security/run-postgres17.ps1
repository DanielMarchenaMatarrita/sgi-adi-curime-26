[CmdletBinding()]
param(
  [switch]$RunSecurityValidation,
  [switch]$RunPrismaValidation,
  [string]$ValidatorImage = 'node:22-alpine',
  [string[]]$ValidatorCommand = @('node', '-e', 'setInterval(() => {}, 2147483647)'),
  [int]$ReadinessTimeoutSeconds = 60,
  [int]$ValidatorTimeoutSeconds = 180,
  [string]$CleanupExecutionId,
  [switch]$ApplyOrphanCleanup
)

$ErrorActionPreference = 'Stop'
$owner = 'atlas-validation'
$disposableLabel = 'com.sgi.curime.disposable'
$executionIdLabel = 'com.sgi.curime.execution-id'
$ownerLabel = 'com.sgi.curime.owner'
$createdAtLabel = 'com.sgi.curime.created-at'
$createdAt = [DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ')
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..\..')).Path
$canonical = Join-Path $repo 'supabase\migrations\20261010000000_sgi_curime_v2_initial.sql'
$security = Join-Path $repo 'database\sql\security\10_3d_a_security.sql'
$seed = Join-Path $PSScriptRoot '00_seed_bootstrap_owner.sql'
$validatorSeed = Join-Path $PSScriptRoot '02_seed_validator_users.sql'
$validatorPrincipals = Join-Path $PSScriptRoot '03_create_validator_principals.sql'
$assertions = Join-Path $PSScriptRoot '01_security_assertions.sql'
$postAssertions = Join-Path $PSScriptRoot '04_verify_validator_results.sql'

function New-ExecutionId {
  $bytes = [byte[]]::new(16)
  [System.Security.Cryptography.RandomNumberGenerator]::Fill($bytes)
  return ([Convert]::ToHexString($bytes)).ToLowerInvariant()
}

function Get-DockerJson([string[]]$Arguments) {
  $json = & docker @Arguments 2>$null
  if ($LASTEXITCODE -ne 0) { throw "Docker command failed: docker $($Arguments -join ' ')" }
  return ($json | ConvertFrom-Json)
}

function Get-Resource([string]$Kind, [string]$Id) {
  return Get-DockerJson @($Kind, 'inspect', $Id, '--format', '{{json .}}')
}

function Assert-NameAvailable([string]$Kind, [string]$Name) {
  & docker $Kind inspect $Name *> $null
  if ($LASTEXITCODE -eq 0) { throw "Refusing existing Docker $Kind name '$Name'." }
}

function Assert-DisposableDatabaseName([string]$Name) {
  if ($Name -eq 'sgi_curime_v2' -or $Name -notmatch '^atlas_security_[a-f0-9]{16}$') {
    throw "Refusing non-disposable database name '$Name'."
  }
}

function Test-ExpectedLabels($Resource, [string]$ExecutionId) {
  $labels = if ($null -ne $Resource.Config) { $Resource.Config.Labels } else { $Resource.Labels }
  if ($null -eq $labels) { return $false }
  return $labels.$disposableLabel -eq 'true' -and
  $labels.$executionIdLabel -eq $ExecutionId -and
  $labels.$ownerLabel -eq $owner -and
  -not [string]::IsNullOrWhiteSpace($labels.$createdAtLabel)
}

function Assert-OwnedResource([string]$Kind, [string]$Id, [string]$ExpectedId, [string]$ExecutionId) {
  $resource = Get-Resource $Kind $Id
  # Docker volumes expose their immutable API identity as Name; other kinds use Id.
  $actualId = if ($Kind -eq 'volume') { $resource.Name } else { $resource.Id }
  if ($actualId -ne $ExpectedId) { throw "Refusing Docker $Kind '$Id': immutable identity changed." }
  if (-not (Test-ExpectedLabels $resource $ExecutionId)) { throw "Refusing Docker $Kind '$Id': ownership labels do not match." }
  return $resource
}

function Remove-OwnedResource([string]$Kind, [string]$Id, [string]$ExpectedId, [string]$ExecutionId) {
  [void](Assert-OwnedResource $Kind $Id $ExpectedId $ExecutionId)
  if ($Kind -eq 'network') { & docker network rm $Id *> $null }
  else { & docker $Kind rm -f $Id *> $null }
  if ($LASTEXITCODE -ne 0) { throw "Docker $Kind removal failed for immutable ID '$Id'." }
  "Removed $Kind ID $ExpectedId"
}

function Assert-PrivateContainer($Container, [bool]$RequiresSourceMount) {
  $publishedBindings = @($Container.HostConfig.PortBindings.PSObject.Properties | Where-Object { $null -ne $_.Value })
  if ($publishedBindings.Count -ne 0) { throw "Refusing container $($Container.Id): published ports detected." }
  if ($RequiresSourceMount) {
    $sourceMount = @($Container.Mounts | Where-Object { $_.Destination -eq '/workspace' })
    if ($sourceMount.Count -ne 1 -or $sourceMount[0].RW -ne $false) {
      throw "Refusing validator $($Container.Id): source mount is not exactly one read-only /workspace mount."
    }
  }
}

function Assert-ValidatorNetwork($Container, [string]$ExpectedNetworkName) {
  $networkNames = @($Container.NetworkSettings.Networks.PSObject.Properties.Name)
  if ($networkNames.Count -ne 1 -or $networkNames[0] -ne $ExpectedNetworkName) {
    throw "Refusing validator $($Container.Id): expected only private network '$ExpectedNetworkName'."
  }
}

function Wait-ForPostgres([string]$ContainerId, [int]$TimeoutSeconds) {
  $deadline = [DateTime]::UtcNow.AddSeconds($TimeoutSeconds)
  do {
    & docker exec $ContainerId pg_isready -U postgres -d $databaseName *> $null
    if ($LASTEXITCODE -eq 0) { return }
    if ([DateTime]::UtcNow -ge $deadline) {
      throw "PostgreSQL readiness timeout after $TimeoutSeconds seconds."
    }
    Start-Sleep -Seconds 1
  } while ($true)
}

function Wait-ForValidator([string]$ContainerId, [int]$TimeoutSeconds) {
  $deadline = [DateTime]::UtcNow.AddSeconds($TimeoutSeconds)
  do {
    $state = (& docker inspect --format '{{.State.Status}}' $ContainerId 2>$null).Trim()
    if ($LASTEXITCODE -ne 0) { throw "Could not inspect validator container '$ContainerId'." }
    if ($state -eq 'exited') {
      $exitCode = [int]((& docker inspect --format '{{.State.ExitCode}}' $ContainerId).Trim())
      if ($exitCode -ne 0) {
        & docker logs $ContainerId
        throw "Prisma validator failed with exit code $exitCode."
      }
      return
    }
    if ([DateTime]::UtcNow -ge $deadline) {
      & docker logs $ContainerId
      throw "Prisma validator timeout after $TimeoutSeconds seconds."
    }
    Start-Sleep -Seconds 1
  } while ($true)
}

function Get-LabeledResourceIds([string]$Kind, [string]$ExecutionId) {
  $filter = "label=$executionIdLabel=$ExecutionId"
  if ($Kind -eq 'container') { return @(& docker container ls -aq --filter $filter) }
  if ($Kind -eq 'network') { return @(& docker network ls -q --filter $filter) }
  return @(& docker volume ls -q --filter $filter)
}

function Invoke-OrphanCleanup([string]$ExecutionId, [bool]$Apply) {
  if ($ExecutionId -notmatch '^[a-f0-9]{32}$') { throw 'CleanupExecutionId must be a 32-character lowercase hexadecimal execution ID.' }
  foreach ($kind in @('container', 'volume', 'network')) {
    foreach ($id in (Get-LabeledResourceIds $kind $ExecutionId)) {
      if ([string]::IsNullOrWhiteSpace($id)) { continue }
      $resource = Get-Resource $kind $id
      $immutableId = if ($kind -eq 'volume') { $resource.Name } else { $resource.Id }
      [void](Assert-OwnedResource $kind $id $immutableId $ExecutionId)
      if ($Apply) {
        Remove-OwnedResource $kind $id $immutableId $ExecutionId
        "Removed orphan $kind ID $immutableId"
      }
      else {
        "DRY RUN: would remove orphan $kind ID $immutableId"
      }
    }
  }
}

if ($CleanupExecutionId) {
  # Explicit-only orphan handling. Without -ApplyOrphanCleanup this is always dry-run.
  Invoke-OrphanCleanup $CleanupExecutionId $ApplyOrphanCleanup
  exit 0
}

if ($ReadinessTimeoutSeconds -lt 1 -or $ValidatorTimeoutSeconds -lt 1) {
  throw 'ReadinessTimeoutSeconds and ValidatorTimeoutSeconds must be positive.'
}
if ($RunPrismaValidation) {
  $RunSecurityValidation = $true
}

$executionId = New-ExecutionId
$suffix = $executionId.Substring(0, 16)
$networkName = "atlas-security-net-$suffix"
$volumeName = "atlas-security-vol-$suffix"
$postgresName = "atlas-security-pg-$suffix"
$validatorName = "atlas-security-validator-$suffix"
$databaseName = "atlas_security_$suffix"
$labels = @('--label', "$disposableLabel=true", '--label', "$executionIdLabel=$executionId", '--label', "$ownerLabel=$owner", '--label', "$createdAtLabel=$createdAt")
$networkId = $null
$volumeId = $null
$postgresId = $null
$validatorId = $null
Assert-DisposableDatabaseName $databaseName

function Invoke-PsqlFile([string]$Path) {
  & docker cp $Path "${postgresId}:/tmp/input.sql"
  if ($LASTEXITCODE -ne 0) { throw "docker cp failed: $Path" }
  # Unix socket in isolated PostgreSQL container; no credential material is supplied.
  & docker exec $postgresId psql -v ON_ERROR_STOP=1 -U postgres -d $databaseName -f /tmp/input.sql
  if ($LASTEXITCODE -ne 0) { throw "psql failed: $Path" }
}

try {
  if ($RunSecurityValidation) {
    $securityInputs = @($canonical, $security, $seed, $validatorSeed, $validatorPrincipals, $assertions)
    if ($RunPrismaValidation) {
      $securityInputs += $postAssertions
    }
    foreach ($path in $securityInputs) {
      if (-not (Test-Path -LiteralPath $path)) { throw "Missing input: $path" }
    }
  }
  Assert-NameAvailable 'network' $networkName
  Assert-NameAvailable 'volume' $volumeName
  Assert-NameAvailable 'container' $postgresName
  Assert-NameAvailable 'container' $validatorName
  "Target database $databaseName (not sgi_curime_v2)"

  $networkId = ((& docker network create --internal @labels $networkName) | Out-String).Trim()
  if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($networkId)) { throw 'Network creation failed.' }
  [void](Assert-OwnedResource 'network' $networkId $networkId $executionId)
  "Created network ID $networkId name $networkName"

  $volumeId = ((& docker volume create @labels $volumeName) | Out-String).Trim()
  if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($volumeId)) { throw 'Volume creation failed.' }
  [void](Assert-OwnedResource 'volume' $volumeId $volumeId $executionId)
  "Created volume ID $volumeId name $volumeName"

  # No -p/--publish. POSTGRES_HOST_AUTH_METHOD=trust permits passwordless traffic only on this private run network.
  $postgresId = ((& docker run -d --name $postgresName --network $networkId --network-alias postgres @labels `
        -e "POSTGRES_DB=$databaseName" -e 'POSTGRES_HOST_AUTH_METHOD=trust' `
        --mount "type=volume,src=$volumeId,dst=/var/lib/postgresql/data" postgres:17) | Out-String).Trim()
  if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($postgresId)) { throw 'PostgreSQL container creation failed.' }
  $postgres = Assert-OwnedResource 'container' $postgresId $postgresId $executionId
  Assert-PrivateContainer $postgres $false
  "Created container ID $postgresId name $postgresName"

  Wait-ForPostgres $postgresId $ReadinessTimeoutSeconds
  if ($RunSecurityValidation) {
    Invoke-PsqlFile $canonical
    Invoke-PsqlFile $seed
    Invoke-PsqlFile $validatorSeed
    Invoke-PsqlFile $security
    Invoke-PsqlFile $security # repeatability check
    Invoke-PsqlFile $validatorPrincipals
    Invoke-PsqlFile $assertions
    'Phase 10.3D-A PostgreSQL 17 validation: PASS'
  }
  else {
    'Disposable harness smoke: PASS (no SQL validation requested)'
  }

  if ($RunPrismaValidation) {
    $validatorArguments = @(
      'run', '-d', '--name', $validatorName, '--network', $networkId
    ) + $labels + @(
      '-e', 'NODE_ENV=test',
      '-e', "AUTH_DATABASE_URL=postgresql://sgi_auth_validator@postgres:5432/${databaseName}?connection_limit=1",
      '-e', "APP_DATABASE_URL=postgresql://sgi_app_validator@postgres:5432/${databaseName}?connection_limit=1",
      '--mount', "type=bind,src=$repo,dst=/workspace,readonly",
      $ValidatorImage
    ) + $ValidatorCommand
    $validatorId = ((& docker @validatorArguments) | Out-String).Trim()
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($validatorId)) { throw 'Validator container creation failed.' }
    $validator = Assert-OwnedResource 'container' $validatorId $validatorId $executionId
    Assert-PrivateContainer $validator $true
    Assert-ValidatorNetwork $validator $networkName
    "Created validator container ID $validatorId name $validatorName"
    Wait-ForValidator $validatorId $ValidatorTimeoutSeconds
    # Preserve focused validator/Jest evidence before finally removes this disposable container.
    & docker logs $validatorId
    if ($LASTEXITCODE -ne 0) { throw "Could not read Prisma validator logs for '$validatorId'." }
    Invoke-PsqlFile $postAssertions
    'Prisma/RLS disposable integration validation: PASS'
  }
}
finally {
  # Reverse order. Every removal re-inspects immutable ID and all ownership labels.
  $cleanupErrors = [System.Collections.Generic.List[string]]::new()
  foreach ($entry in @(
      @{ Kind = 'container'; Id = $validatorId },
      @{ Kind = 'container'; Id = $postgresId },
      @{ Kind = 'volume'; Id = $volumeId },
      @{ Kind = 'network'; Id = $networkId }
    )) {
    if (-not [string]::IsNullOrWhiteSpace($entry.Id)) {
      try {
        Remove-OwnedResource $entry.Kind $entry.Id $entry.Id $executionId
      }
      catch {
        $message = "Cleanup failure for $($entry.Kind) ID $($entry.Id): $($_.Exception.Message)"
        $cleanupErrors.Add($message)
        $message
      }
    }
  }
  if ($cleanupErrors.Count -ne 0) {
    throw "Disposable Docker cleanup incomplete ($($cleanupErrors.Count) failure(s)). Review emitted cleanup errors."
  }
  'Disposable Docker resources: cleaned'
}
