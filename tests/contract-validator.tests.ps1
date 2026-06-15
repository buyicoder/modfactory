param([string]$ProjectDir = (Resolve-Path (Join-Path $PSScriptRoot "..")))

Set-StrictMode -Version Latest

$validator = Join-Path $ProjectDir "scripts\validate-contract.ps1"
$fixtureDir = Join-Path ([System.IO.Path]::GetTempPath()) "modfactory-contract-validator-tests"
New-Item -ItemType Directory -Path $fixtureDir -Force | Out-Null

function Write-TestJson {
    param(
        [Parameter(Mandatory=$true)][string]$Path,
        [Parameter(Mandatory=$true)][string]$Json
    )
    $utf8 = [System.Text.UTF8Encoding]::new($false)
    [System.IO.File]::WriteAllText($Path, $Json.Trim() + [Environment]::NewLine, $utf8)
}

function Invoke-ValidatorMustPass {
    param([Parameter(Mandatory=$true)][string]$Path)
    & powershell -NoProfile -File $validator -ContractPath $Path
    if ($LASTEXITCODE -ne 0) {
        throw "Expected validator to pass for $Path"
    }
}

function Invoke-ValidatorMustFail {
    param([Parameter(Mandatory=$true)][string]$Path)
    & powershell -NoProfile -File $validator -ContractPath $Path
    if ($LASTEXITCODE -eq 0) {
        throw "Expected validator to fail for $Path"
    }
}

$entityContract = Join-Path $ProjectDir "tests\fixtures\entity\entity.contract.json"
Invoke-ValidatorMustPass -Path $entityContract

$assetContract = Join-Path $fixtureDir "asset.contract.json"
Write-TestJson -Path $assetContract -Json @'
{
  "schemaVersion": 1,
  "assetId": "modid:dark_iron_ingot",
  "assetType": "item_texture",
  "source": {
    "type": "vanilla_texture",
    "id": "minecraft:item/iron_ingot"
  },
  "transform": {
    "type": "palette_remap",
    "tool": "derive-vanilla-item-texture.ps1"
  },
  "output": {
    "path": "src/main/resources/assets/modid/textures/item/dark_iron_ingot.png",
    "width": 16,
    "height": 16,
    "preserveAlpha": true,
    "preserveDimensions": true
  }
}
'@
Invoke-ValidatorMustPass -Path $assetContract

$animationContract = Join-Path $fixtureDir "animation.contract.json"
Write-TestJson -Path $animationContract -Json @'
{
  "schemaVersion": 1,
  "animationId": "modid:dark_iron_golem",
  "target": "modid:dark_iron_golem",
  "clips": [
    {
      "name": "attack_slam",
      "loop": false,
      "lengthSeconds": 0.8,
      "runtimeTrigger": "on_attack"
    }
  ]
}
'@
Invoke-ValidatorMustPass -Path $animationContract

$qaReport = Join-Path $fixtureDir "qa.report.json"
Write-TestJson -Path $qaReport -Json @'
{
  "schemaVersion": 1,
  "targetId": "modid:dark_iron_golem",
  "commands": [
    {
      "command": "gradlew build",
      "exitCode": 0,
      "summary": "Build passed"
    }
  ],
  "evidenceSummary": "Contract validator and build passed.",
  "manualFindings": [],
  "openRisks": []
}
'@
Invoke-ValidatorMustPass -Path $qaReport

$invalidAssetContract = Join-Path $fixtureDir "invalid.asset.contract.json"
Write-TestJson -Path $invalidAssetContract -Json @'
{
  "schemaVersion": 1,
  "assetId": "modid:broken",
  "assetType": "item_texture",
  "source": {
    "type": "vanilla_texture"
  },
  "output": {
    "path": "src/main/resources/assets/modid/textures/item/broken.png",
    "width": 16,
    "height": 16
  }
}
'@
Invoke-ValidatorMustFail -Path $invalidAssetContract

Write-Host "PASS contract validator fixture tests"
