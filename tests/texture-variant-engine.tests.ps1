param([string]$ProjectDir = (Resolve-Path (Join-Path $PSScriptRoot "..")))

Set-StrictMode -Version Latest

$engine = Join-Path $ProjectDir "scripts\texture-variant-engine.ps1"
$source = Join-Path $ProjectDir "src\main\resources\assets\modid\textures\entity\dark_iron_golem.png"
$contract = Join-Path $ProjectDir "tests\fixtures\entity\entity.contract.json"
$outDir = Join-Path ([System.IO.Path]::GetTempPath()) "modfactory-texture-variant-tests"
New-Item -ItemType Directory -Path $outDir -Force | Out-Null

foreach ($theme in @("dark-forged","frost","lava","storm","ancient","corrupted")) {
    $out = Join-Path $outDir "$theme.png"
    & powershell -NoProfile -File $engine -SourcePng $source -OutputPath $out -Theme $theme -ContractPath $contract
    if ($LASTEXITCODE -ne 0) {
        throw "Texture variant engine failed for theme: $theme"
    }
}

Write-Host "PASS texture variant fixture tests"
