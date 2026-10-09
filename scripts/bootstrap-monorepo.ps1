#Requires -Version 7.0
<#
.SYNOPSIS
  Inicializa el repositorio remoto vacío con un README mínimo en main y
  publica el monorepo/documentación completa en una rama de trabajo.
.DESCRIPTION
  Ejecutar únicamente desde la raíz de la carpeta extraída.
  No hace merge ni PR; no toca el repositorio compartido del equipo.
  Requiere Git configurado y acceso de escritura autenticado a GitHub.
  Detiene la operación si el destino ya tiene referencias o existe .git local.
#>
[CmdletBinding()]
param(
    [string]$RemoteUrl = 'https://github.com/DanielMarchenaMatarrita/sgi-adi-curime-26.git',
    [string]$WorkBranch = 'chore/bootstrap-monorepo-v2'
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$approvedRemoteUrl = 'https://github.com/DanielMarchenaMatarrita/sgi-adi-curime-26.git'
$approvedWorkBranch = 'chore/bootstrap-monorepo-v2'
if ($RemoteUrl -cne $approvedRemoteUrl) {
    throw "RemoteUrl no aprobado. Destino permitido: $approvedRemoteUrl"
}
if ($WorkBranch -cne $approvedWorkBranch) {
    throw "WorkBranch no aprobada. Rama permitida: $approvedWorkBranch"
}
$root = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $root

function Invoke-Git {
    param([string[]]$Arguments)
    & git @Arguments
    if ($LASTEXITCODE -ne 0) { throw "Falló git $($Arguments -join ' ') (código $LASTEXITCODE)." }
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw 'Git no está disponible en PATH.' }
if (Test-Path -LiteralPath (Join-Path $root '.git')) { throw 'Ya existe .git en esta carpeta. No se modifica ningún repositorio inicializado.' }
foreach ($needed in @('README.md','AGENTS.md','pnpm-workspace.yaml','docs/README.md','docs/data/target-v2/entity-inventory.md')) {
    if (-not (Test-Path -LiteralPath (Join-Path $root $needed))) { throw "Falta un archivo del paquete: $needed" }
}
$author = (& git config --global user.name)
$mail = (& git config --global user.email)
if ([string]::IsNullOrWhiteSpace($author) -or [string]::IsNullOrWhiteSpace($mail)) {
    throw 'Configura primero git config --global user.name y user.email para crear commits.'
}
Write-Host "Comprobando que $RemoteUrl no tenga commits..."
$refs = @(& git ls-remote $RemoteUrl)
if ($LASTEXITCODE -ne 0) { throw 'No se pudo consultar el repositorio remoto. Comprueba conexión y autenticación.' }
if ($refs.Count -gt 0) { throw 'El repositorio remoto ya tiene referencias. Detener para no sobrescribir trabajo remoto.' }

$readmePath = Join-Path $root 'README.md'
$fullReadme = [IO.File]::ReadAllText($readmePath)
$utf8 = [Text.UTF8Encoding]::new($false)
$bootstrap = @'
# SGI · ADI Curime 26

Repositorio independiente para el rediseño V2 de SGI-Curime.

La estructura del monorepo y su documentación se publican primero en una rama de trabajo y se integrarán a `main` únicamente después de revisión.

**Estado:** inicio del repositorio; la implementación funcional y las migraciones no han comenzado.
'@
try {
    Invoke-Git -Arguments @('init','-b','main')
    Invoke-Git -Arguments @('remote','add','origin',$RemoteUrl)
    [IO.File]::WriteAllText($readmePath, $bootstrap + "`n", $utf8)
    Invoke-Git -Arguments @('add','--','README.md')
    Invoke-Git -Arguments @('commit','-m','chore: initialize independent SGI V2 repository')
    Invoke-Git -Arguments @('push','-u','origin','main')

    Invoke-Git -Arguments @('switch','-c',$WorkBranch)
    [IO.File]::WriteAllText($readmePath, $fullReadme, $utf8)
    Invoke-Git -Arguments @('add','--','.editorconfig','.gitignore','AGENTS.md','README.md','apps','docs','infra','packages','scripts','package.json','pnpm-workspace.yaml')
    Invoke-Git -Arguments @('diff','--cached','--check')
    Invoke-Git -Arguments @('commit','-m','docs(architecture): bootstrap V2 monorepo and design atlas')
    Invoke-Git -Arguments @('push','-u','origin',$WorkBranch)
    Write-Host ''
    Write-Host "Rama publicada: $WorkBranch" -ForegroundColor Green
    Write-Host "Consulta: https://github.com/DanielMarchenaMatarrita/sgi-adi-curime-26/tree/$WorkBranch"
    Write-Host 'Siguiente paso: revisar la rama y abrir un Pull Request hacia main; NO se hace merge automáticamente.'
} finally {
    # Protege el README íntegro si una operación falla después del bootstrap.
    [IO.File]::WriteAllText($readmePath, $fullReadme, $utf8)
}
