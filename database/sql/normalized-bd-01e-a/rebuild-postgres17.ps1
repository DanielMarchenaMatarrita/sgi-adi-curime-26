[CmdletBinding()]
param(
  [int]$ReadinessTimeoutSeconds = 60,
  [string]$PostgresImage = 'postgres:17@sha256:e42539a54ee3e82e21f19d7eded61b579869585f86b90b5e851ff0d3dd8b4001',
  [switch]$AllowUnpinnedLocalImage,
  [switch]$SkipPrismaValidation
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
$executionId = ([guid]::NewGuid().ToString('N')).Substring(0,16)
$containerName = "bd01ea-pg-$executionId"
$databaseName = "atlas_security_$executionId"
$label = 'com.sgi.curime.bd01ea-disposable=true'
$containerId = $null
$pinnedImage = 'postgres:17@sha256:e42539a54ee3e82e21f19d7eded61b579869585f86b90b5e851ff0d3dd8b4001'

function Invoke-SqlFile([string]$Path, [hashtable]$Variables = @{}) {
  docker cp $Path "${containerId}:/tmp/input.sql" | Out-Null
  if ($LASTEXITCODE -ne 0) { throw "docker cp failed: $Path" }
  $args = @('exec',$containerId,'psql','-X','-v','ON_ERROR_STOP=1')
  foreach ($entry in $Variables.GetEnumerator()) { $args += @('-v',"$($entry.Key)=$($entry.Value)") }
  $args += @('-U','postgres','-d',$databaseName,'-f','/tmp/input.sql')
  & docker @args
  if ($LASTEXITCODE -ne 0) { throw "psql failed: $Path" }
}

function Assert-Fails([string]$Path, [string]$ExpectedSqlState, [string]$ExpectedMessagePattern) {
  docker cp $Path "${containerId}:/tmp/expected-failure.sql" | Out-Null
  $output = (& docker exec $containerId psql -X -v ON_ERROR_STOP=1 -v VERBOSITY=verbose -U postgres -d $databaseName -f /tmp/expected-failure.sql 2>&1 | Out-String)
  if ($LASTEXITCODE -eq 0) { throw "Expected integrity rejection did not occur: $Path" }
  if ($output -notmatch "ERROR:\s+$([regex]::Escape($ExpectedSqlState)):") {
    throw "Wrong SQLSTATE for expected rejection $Path. Expected $ExpectedSqlState. Output: $output"
  }
  if ($output -notmatch $ExpectedMessagePattern) {
    throw "Wrong error cause for expected rejection $Path. Expected pattern '$ExpectedMessagePattern'. Output: $output"
  }
  "PASS expected rejection: $([IO.Path]::GetFileName($Path)) SQLSTATE=$ExpectedSqlState"
}

function Get-CatalogSnapshot {
  $query = Join-Path $PSScriptRoot 'tests/catalog-snapshot.sql'
  docker cp $query "${containerId}:/tmp/catalog-snapshot.sql" | Out-Null
  if ($LASTEXITCODE -ne 0) { throw 'Could not copy catalog snapshot query.' }
  $snapshot = (& docker exec $containerId psql -X -v ON_ERROR_STOP=1 -At -U postgres -d $databaseName -f /tmp/catalog-snapshot.sql | Out-String).Trim()
  if ($LASTEXITCODE -ne 0 -or -not $snapshot) { throw 'Could not capture catalog snapshot.' }
  return $snapshot
}

try {
  if ($PostgresImage -ne $pinnedImage -and -not $AllowUnpinnedLocalImage) {
    throw 'Non-pinned PostgreSQL image requires explicit -AllowUnpinnedLocalImage and is not reproducible evidence.'
  }
  docker image inspect $PostgresImage *> $null
  if ($LASTEXITCODE -ne 0) {
    throw "Pinned PostgreSQL image is not available locally. Refusing network pull: $PostgresImage"
  }
  if (-not $SkipPrismaValidation) {
    $previousDatabaseUrl = $env:DATABASE_URL
    try {
      $env:DATABASE_URL = 'postgresql://invalid:invalid@127.0.0.1:1/invalid'
      & pnpm exec prisma validate --schema (Join-Path $root 'database/prisma/schema.prisma')
      if ($LASTEXITCODE -ne 0) { throw 'Prisma schema validation failed.' }
      'Prisma schema validation: PASS'
    }
    finally { $env:DATABASE_URL = $previousDatabaseUrl }
  }
  $containerId = (docker run -d --name $containerName --label $label --network none `
    --tmpfs /var/lib/postgresql/data:rw,noexec,nosuid,size=1g `
    -e "POSTGRES_DB=$databaseName" -e POSTGRES_HOST_AUTH_METHOD=trust $PostgresImage).Trim()
  if ($LASTEXITCODE -ne 0 -or -not $containerId) { throw 'Could not create isolated PostgreSQL 17 container.' }
  $deadline = [DateTime]::UtcNow.AddSeconds($ReadinessTimeoutSeconds)
  do {
    docker exec $containerId pg_isready -U postgres -d $databaseName *> $null
    if ($LASTEXITCODE -eq 0) { break }
    if ([DateTime]::UtcNow -ge $deadline) { throw 'PostgreSQL readiness timeout.' }
    Start-Sleep -Seconds 1
  } while ($true)

  Invoke-SqlFile (Join-Path $PSScriptRoot '00_schema.sql')
  Invoke-SqlFile (Join-Path $PSScriptRoot 'tests/security/00_seed_bootstrap_owner.sql')
  Invoke-SqlFile (Join-Path $PSScriptRoot 'tests/security/02_seed_validator_users.sql')
  Invoke-SqlFile (Join-Path $PSScriptRoot 'tests/security/05_seed_auth_login_fixtures.sql') @{ auth_login_password_hash = 'isolated-validation-not-a-real-secret' }
  Invoke-SqlFile (Join-Path $PSScriptRoot 'tests/security/07_seed_rbac_effective_permission_fixtures.sql')
  Invoke-SqlFile (Join-Path $PSScriptRoot 'tests/security/08_seed_affiliate_read_fixture.sql')
  Invoke-SqlFile (Join-Path $PSScriptRoot '01_runtime_security.sql')
  Invoke-SqlFile (Join-Path $PSScriptRoot 'tests/security/03_create_validator_principals.sql')
  Invoke-SqlFile (Join-Path $PSScriptRoot 'tests/00_structure.sql')
  Invoke-SqlFile (Join-Path $PSScriptRoot 'tests/01_integrity_catalog.sql')
  $expectedCatalogPath = Join-Path $PSScriptRoot 'tests/expected-catalog.json'
  if (-not (Test-Path -LiteralPath $expectedCatalogPath)) { throw "Missing catalog manifest: $expectedCatalogPath" }
  $expectedCatalog = (Get-Content -Raw -LiteralPath $expectedCatalogPath).Trim()
  $actualCatalog = Get-CatalogSnapshot
  if ($actualCatalog -cne $expectedCatalog) {
    $expectedHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $expectedCatalogPath).Hash.ToLowerInvariant()
    $actualHash = [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData([Text.Encoding]::UTF8.GetBytes($actualCatalog))).ToLowerInvariant()
    throw "Catalog object equivalence failed. expected_sha256=$expectedHash actual_sha256=$actualHash"
  }
  'Catalog object equivalence: PASS'
  Invoke-SqlFile (Join-Path $PSScriptRoot 'tests/security/01_security_assertions.sql')
  Invoke-SqlFile (Join-Path $PSScriptRoot 'tests/integrity/a5-synthetic-validation.sql')
  Invoke-SqlFile (Join-Path $PSScriptRoot 'tests/integrity/a5-exclude-allowed.sql')
  Assert-Fails (Join-Path $PSScriptRoot 'tests/integrity/a5-trigger-loan-close-fail.sql') '23514' 'Cannot close loan'
  Assert-Fails (Join-Path $PSScriptRoot 'tests/integrity/a5-trigger-return-limit-fail.sql') '23514' 'Return \+ shortage .* exceeds checkout allocation'
  Assert-Fails (Join-Path $PSScriptRoot 'tests/integrity/a5-trigger-shortage-limit-fail.sql') '23514' 'Return \+ shortage .* exceeds checkout allocation'
  Assert-Fails (Join-Path $PSScriptRoot 'tests/integrity/a5-exclude-conflict-fail.sql') '23P01' 'ex_resource_unavailabilities_rule'
  Assert-Fails (Join-Path $PSScriptRoot 'tests/integrity/a5-rls-denied-write-fail.sql') '42501' 'row-level security policy.*audit_logs'
  'VERIFIED BD-01E-A PostgreSQL 17 isolated reconstruction: PASS'
}
finally {
  if ($containerId) {
    $actualLabel = (docker inspect --format "{{index .Config.Labels `"com.sgi.curime.bd01ea-disposable`"}}" $containerId 2>$null).Trim()
    if ($actualLabel -eq 'true') { docker rm -f $containerId | Out-Null }
    else { Write-Warning "Container not removed because ownership label is absent: $containerId" }
  }
}
