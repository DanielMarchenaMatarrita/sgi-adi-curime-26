[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$container = 'sgi-v2-103d-a-pg17'
$network = 'sgi-v2-103d-a-net'
$volume = 'sgi-v2-103d-a-data'
$createdContainer = $false
$createdNetwork = $false
$createdVolume = $false
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..\..')).Path
$canonical = Join-Path $repo 'supabase\migrations\20261010000000_sgi_curime_v2_initial.sql'
$security = Join-Path $repo 'database\sql\security\10_3d_a_security.sql'
$seed = Join-Path $PSScriptRoot '00_seed_bootstrap_owner.sql'
$assertions = Join-Path $PSScriptRoot '01_security_assertions.sql'

function Assert-MissingDockerResource([string]$kind, [string]$name) {
  & docker $kind inspect $name *> $null
  if ($LASTEXITCODE -eq 0) { throw "Refusing existing Docker $kind '$name'; runner will not manipulate it." }
}
function Invoke-PsqlFile([string]$path) {
  & docker cp $path "${container}:/tmp/input.sql"
  if ($LASTEXITCODE -ne 0) { throw "docker cp failed: $path" }
  & docker exec $container psql -v ON_ERROR_STOP=1 -U postgres -d sgi_103d_a -f /tmp/input.sql
  if ($LASTEXITCODE -ne 0) { throw "psql failed: $path" }
}

try {
  foreach ($path in @($canonical, $security, $seed, $assertions)) { if (-not (Test-Path -LiteralPath $path)) { throw "Missing input: $path" } }
  Assert-MissingDockerResource 'network' $network
  Assert-MissingDockerResource 'volume' $volume
  Assert-MissingDockerResource 'container' $container
  & docker network create $network; if ($LASTEXITCODE -ne 0) { throw 'network creation failed' }; $createdNetwork = $true
  & docker volume create $volume; if ($LASTEXITCODE -ne 0) { throw 'volume creation failed' }; $createdVolume = $true
  & docker run -d --name $container --network $network -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=sgi_103d_a -v "${volume}:/var/lib/postgresql/data" postgres:17
  if ($LASTEXITCODE -ne 0) { throw 'container creation failed' }; $createdContainer = $true
  do { Start-Sleep -Seconds 1; & docker exec $container pg_isready -U postgres -d sgi_103d_a *> $null } while ($LASTEXITCODE -ne 0)
  Invoke-PsqlFile $canonical
  Invoke-PsqlFile $seed
  Invoke-PsqlFile $security
  Invoke-PsqlFile $security # repeatability check
  Invoke-PsqlFile $assertions
  'Phase 10.3D-A PostgreSQL 17 validation: PASS'
}
finally {
  if ($createdContainer) { & docker rm -f $container *> $null }
  if ($createdVolume) { & docker volume rm $volume *> $null }
  if ($createdNetwork) { & docker network rm $network *> $null }
  'Phase 10.3D-A disposable Docker resources: cleaned'
}
