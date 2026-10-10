# PowerShell 7. Run from repository root after placing this package under database/sql/v2.
# Creates ONLY a new disposable DB; never drops the existing sgi_curime_v2.
param(
  [string]$Container = 'sgi-curime-v2-postgres-1',
  [string]$AdminUser = 'sgi_admin',
  [string]$TestDatabase = 'sgi_curime_v2_ddl_test'
)
$ErrorActionPreference = 'Stop'
if ($TestDatabase -notmatch '^sgi_curime_v2_ddl_test[a-z0-9_]*$') { throw 'Refusing unsafe test database name.' }
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$migration = Join-Path $root '..\supabase\migrations\20261010000000_sgi_curime_v2_initial.sql'
$verify = Join-Path $root '..\database\sql\v2\09_verify.sql'
$smoke = Join-Path $root '..\database\sql\v2\10_smoke_rollback.sql'
foreach($file in @($migration,$verify,$smoke)) { if (!(Test-Path $file)) {throw "File not found: $file"} }
$running = docker inspect --format '{{.State.Running}}' $Container
if ($LASTEXITCODE -ne 0 -or $running -ne 'true') {throw "Postgres container not running: $Container"}
$found = docker exec $Container psql -X -U $AdminUser -d postgres -At -c "SELECT 1 FROM pg_database WHERE datname='$TestDatabase';"
if ($LASTEXITCODE -ne 0) {throw 'Could not inspect databases.'}
if ($found -eq '1') {throw "Test database already exists: $TestDatabase. Use an unused test name; never delete it automatically."}
Write-Host "Creating disposable database: $TestDatabase"
docker exec $Container psql -X -v ON_ERROR_STOP=1 -U $AdminUser -d postgres -c "CREATE DATABASE $TestDatabase OWNER $AdminUser;"
if ($LASTEXITCODE -ne 0) {throw 'Could not create test database.'}
foreach ($file in @($migration,$verify,$smoke)) {
  Write-Host "Executing $([IO.Path]::GetFileName($file)) against $TestDatabase ..."
  Get-Content -Raw -Encoding UTF8 $file | docker exec -i $Container psql -X -v ON_ERROR_STOP=1 -U $AdminUser -d $TestDatabase
  if ($LASTEXITCODE -ne 0) {throw "FAILED: $file. Test DB preserved for troubleshooting: $TestDatabase"}
}
Write-Host "PASS: SQL migration, schema verification and rollback smoke tests in $TestDatabase" -ForegroundColor Green
Write-Host "Existing sgi_curime_v2 and Supabase have NOT been modified."
