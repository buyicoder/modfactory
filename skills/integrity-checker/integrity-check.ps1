# Thin compatibility wrapper. The canonical checker lives in scripts/ so skill
# copies cannot drift from CI behavior.
param([string]$ProjectDir = ".")

$root = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$checker = Join-Path $root "scripts\integrity-check.ps1"
& powershell -NoProfile -ExecutionPolicy Bypass -File $checker -ProjectDir $ProjectDir
exit $LASTEXITCODE
