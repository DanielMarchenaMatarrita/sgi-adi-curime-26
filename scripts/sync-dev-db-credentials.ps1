$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$envPath = Join-Path $repoRoot '.env.local'
$container = 'sgi-curime-v2-postgres-1'
$database = 'sgi_curime_v2'

if (-not (Test-Path -LiteralPath $envPath)) {
  throw '.env.local does not exist.'
}

$envContent = [IO.File]::ReadAllText($envPath)
$authPattern = '(?m)^AUTH_DATABASE_URL=postgresql://sgi_auth_login_dev:[^@\r\n]*@127\.0\.0\.1:5433/sgi_curime_v2(?:\?[^\r\n]*)?$'
$appPattern = '(?m)^APP_DATABASE_URL=postgresql://sgi_app_login_dev:[^@\r\n]*@127\.0\.0\.1:5433/sgi_curime_v2(?:\?[^\r\n]*)?$'

if ([regex]::Matches($envContent, $authPattern).Count -ne 1) {
  throw 'AUTH_DATABASE_URL does not match expected local target.'
}
if ([regex]::Matches($envContent, $appPattern).Count -ne 1) {
  throw 'APP_DATABASE_URL does not match expected local target.'
}

$adminCheck = & docker exec $container psql -X -q -v ON_ERROR_STOP=1 `
  -U sgi_admin -d $database -tAc "SELECT current_user = 'sgi_admin';"
if ($LASTEXITCODE -ne 0 -or $adminCheck.Trim() -ne 't') {
  throw 'Administrative connection unavailable; no password was changed.'
}

$securePassword = Read-Host 'Nueva contraseña local compartida para AUTH y APP' -AsSecureString
$passwordPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)

try {
  $password = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($passwordPointer)
  if ([string]::IsNullOrEmpty($password)) {
    throw 'Password cannot be empty.'
  }

  $sqlPassword = $password.Replace("'", "''")
  $sql = @"
BEGIN;
ALTER ROLE "sgi_auth_login_dev" PASSWORD '$sqlPassword';
ALTER ROLE "sgi_app_login_dev" PASSWORD '$sqlPassword';
COMMIT;
"@

  $sql | & docker exec -i $container psql -X -q -v ON_ERROR_STOP=1 `
    -U sgi_admin -d $database
  if ($LASTEXITCODE -ne 0) {
    throw 'PostgreSQL credential synchronization failed.'
  }

  $encodedPassword = [Uri]::EscapeDataString($password)
  $envContent = [regex]::Replace(
    $envContent,
    '(?m)^(AUTH_DATABASE_URL=postgresql://sgi_auth_login_dev:)[^@\r\n]*(@127\.0\.0\.1:5433/sgi_curime_v2(?:\?[^\r\n]*)?)$',
    { param($match) $match.Groups[1].Value + $encodedPassword + $match.Groups[2].Value }
  )
  $envContent = [regex]::Replace(
    $envContent,
    '(?m)^(APP_DATABASE_URL=postgresql://sgi_app_login_dev:)[^@\r\n]*(@127\.0\.0\.1:5433/sgi_curime_v2(?:\?[^\r\n]*)?)$',
    { param($match) $match.Groups[1].Value + $encodedPassword + $match.Groups[2].Value }
  )
  [IO.File]::WriteAllText($envPath, $envContent, [Text.UTF8Encoding]::new($false))
} finally {
  if ($null -ne $passwordPointer) {
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($passwordPointer)
  }
  $password = $null
  $sqlPassword = $null
  $sql = $null
}

& pnpm local:prisma:verify
if ($LASTEXITCODE -ne 0) {
  throw 'Prisma verification failed after credential synchronization.'
}
