param(
    [Parameter(Mandatory=$true)][string]$ProjectDir,
    [Parameter(Mandatory=$true)][string]$ContractPath
)

Set-StrictMode -Version Latest
. "$PSScriptRoot\lib\EntityContract.ps1"

$errors = @()
$warnings = @()
$contract = Read-EntityContract -Path $ContractPath
$errors += @(Test-EntityContractShape -Contract $contract)
$resourcePaths = Get-EntityResourcePathsFromContract -Contract $contract

function Add-FileCheck {
    param([string]$Label, [string]$RelativePath)
    if (-not $RelativePath) {
        $script:warnings += "SKIP ${Label}: no path in contract"
        return
    }
    $full = Resolve-ModFactoryPath -ProjectDir $ProjectDir -RelativePath $RelativePath
    if (-not (Test-Path $full)) {
        $script:errors += "MISSING ${Label}: $RelativePath"
    }
}

function Test-ProjectFile {
    param([Parameter(Mandatory=$true)][string]$RelativePath)
    $full = Resolve-ModFactoryPath -ProjectDir $ProjectDir -RelativePath $RelativePath
    return Test-Path $full
}

function Read-ProjectText {
    param([Parameter(Mandatory=$true)][string]$RelativePath)
    $full = Resolve-ModFactoryPath -ProjectDir $ProjectDir -RelativePath $RelativePath
    if (-not (Test-Path $full)) {
        return $null
    }
    return [System.IO.File]::ReadAllText($full)
}

function Add-ResourceFileCheck {
    param([string]$Label, [string]$RelativePath)
    if (-not (Test-ProjectFile -RelativePath $RelativePath)) {
        $script:errors += "MISSING ${Label}: $RelativePath"
    }
}

Add-FileCheck "texture" $contract.texture.path
Add-FileCheck "model" $contract.model.javaPath
Add-FileCheck "renderer" $contract.renderer.javaPath

$texturePath = Resolve-ModFactoryPath -ProjectDir $ProjectDir -RelativePath $contract.texture.path
if (Test-Path $texturePath) {
    Add-Type -AssemblyName System.Drawing
    $img = [System.Drawing.Image]::FromFile($texturePath)
    try {
        if ($img.Width -ne [int]$contract.texture.width -or $img.Height -ne [int]$contract.texture.height) {
            $errors += "Texture dimensions mismatch: actual=$($img.Width)x$($img.Height) contract=$($contract.texture.width)x$($contract.texture.height)"
        }
    } finally {
        $img.Dispose()
    }
}

if ($contract.model.javaPath) {
    $modelPath = Resolve-ModFactoryPath -ProjectDir $ProjectDir -RelativePath $contract.model.javaPath
    if (Test-Path $modelPath) {
        $modelText = [System.IO.File]::ReadAllText($modelPath)
        $expected = "TexturedModelData.of(data, $($contract.model.textureWidth), $($contract.model.textureHeight))"
        if (-not $modelText.Contains($expected)) {
            $errors += "Model does not declare expected texture size: $expected"
        }
        foreach ($part in $contract.model.parts) {
            if (-not $modelText.Contains("`"$part`"")) {
                $warnings += "Model contract part not found in Java model: $part"
            }
        }
    }
}

if ($contract.renderer.javaPath) {
    $rendererText = Read-ProjectText -RelativePath $contract.renderer.javaPath
    if ($rendererText) {
        $textureIdentifier = [string]$contract.renderer.textureIdentifier
        $texturePath = $textureIdentifier
        if ($textureIdentifier.Contains(":")) {
            $texturePath = $textureIdentifier.Split(":", 2)[1]
        }
        if (-not ($rendererText.Contains($textureIdentifier) -or $rendererText.Contains($texturePath))) {
            $errors += "Renderer does not reference expected texture identifier: $textureIdentifier"
        }
    }
}

Add-ResourceFileCheck "lang" $resourcePaths.langFile
$langText = Read-ProjectText -RelativePath $resourcePaths.langFile
if ($langText) {
    if (-not $langText.Contains("`"$($resourcePaths.entityLangKey)`"")) {
        $errors += "Missing entity lang key: $($resourcePaths.entityLangKey)"
    }
    if ($resourcePaths.Contains("spawnEggLangKey") -and -not $langText.Contains("`"$($resourcePaths.spawnEggLangKey)`"")) {
        $errors += "Missing spawn egg lang key: $($resourcePaths.spawnEggLangKey)"
    }
}

$noLoot = $false
if ($contract.PSObject.Properties["loot"] -and $contract.loot.PSObject.Properties["noDrop"]) {
    $noLoot = [bool]$contract.loot.noDrop
}
if (-not $noLoot) {
    Add-ResourceFileCheck "loot table" $resourcePaths.lootTable
}

if ($resourcePaths.Contains("spawnEggItem")) {
    Add-ResourceFileCheck "spawn egg item mapping" $resourcePaths.spawnEggItem
    Add-ResourceFileCheck "spawn egg item model" $resourcePaths.spawnEggModel
}

$registryFiles = @()
if ($contract.runtime.PSObject.Properties["registryPath"] -and $contract.runtime.registryPath) {
    $registryPath = Resolve-ModFactoryPath -ProjectDir $ProjectDir -RelativePath $contract.runtime.registryPath
    if (Test-Path $registryPath) {
        $registryFiles = @(Get-Item $registryPath)
    } else {
        $errors += "MISSING entity registry: $($contract.runtime.registryPath)"
    }
} else {
    $registryFiles = @(Get-ChildItem -Path $ProjectDir -Recurse -Filter "ModEntityTypes.java" -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch "\\build\\" })
}
$foundEntityTypeField = $false
foreach ($registryFile in $registryFiles) {
    $registryText = [System.IO.File]::ReadAllText($registryFile.FullName)
    if ($registryText.Contains($contract.runtime.entityTypeField)) {
        $foundEntityTypeField = $true
        if ($contract.runtime.PSObject.Properties["dimensions"]) {
            $width = [string]$contract.runtime.dimensions.width
            $height = [string]$contract.runtime.dimensions.height
            if (-not ($registryText.Contains(".dimensions($($width)F, $($height)F)") -or
                $registryText.Contains(".dimensions($width, $height)") -or
                $registryText.Contains("EntityDimensions.fixed($($width)F, $($height)F)"))) {
                $errors += "Entity registry dimensions do not match contract exactly: $($contract.runtime.entityTypeField)"
            }
        }
        break
    }
}
if ($registryFiles.Count -gt 0 -and -not $foundEntityTypeField) {
    $errors += "Missing runtime entityTypeField in registry code: $($contract.runtime.entityTypeField)"
} elseif ($registryFiles.Count -eq 0) {
    $warnings += "SKIP runtime registry: no ModEntityTypes.java or runtime.registryPath supplied"
}

Write-Host "=== ENTITY ASSET VALIDATION ==="
Write-Host "Contract: $ContractPath"
if ($warnings.Count) {
    Write-Host "WARNINGS:"
    $warnings | ForEach-Object { Write-Host "  $_" }
}
if ($errors.Count) {
    Write-Host "FAILURES:"
    $errors | ForEach-Object { Write-Host "  $_" }
    exit 1
}

Write-Host "PASS"
