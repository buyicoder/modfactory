param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("golem","humanoid","quadruped")]
    [string]$Template,
    [Parameter(Mandatory=$true)][string]$EntityName,
    [string]$ProjectDir = ".",
    [string]$ModId = "modid",
    [double]$BodyScale = 1.0,
    [double]$HeadScale = 1.0,
    [double]$LimbLength = 1.0,
    [double]$Bulk = 1.0,
    [switch]$Horns,
    [switch]$Spikes,
    [switch]$Wings,
    [switch]$Tail,
    [switch]$ArmorPlates
)

Set-StrictMode -Version Latest
. "$PSScriptRoot\lib\ModFactory.Path.ps1"

function Scale-Point {
    param([object[]]$Point, [string]$ScaleKind)
    $xScale = $Bulk
    $yScale = 1.0
    $zScale = $Bulk

    if ($ScaleKind -eq "head") {
        $xScale *= $HeadScale
        $yScale *= $HeadScale
        $zScale *= $HeadScale
    } elseif ($ScaleKind -eq "body") {
        $xScale *= $BodyScale
        $yScale *= $BodyScale
        $zScale *= $BodyScale
    } elseif ($ScaleKind -eq "limb") {
        $yScale *= $LimbLength
    }

    return @(
        [Math]::Round(([double]$Point[0]) * $xScale, 3),
        [Math]::Round(([double]$Point[1]) * $yScale, 3),
        [Math]::Round(([double]$Point[2]) * $zScale, 3)
    )
}

function New-CubeElement {
    param(
        [string]$Name,
        [object[]]$From,
        [object[]]$To,
        [object[]]$Uv,
        [string]$ScaleKind = "body"
    )

    return [ordered]@{
        name = $Name
        type = "cube"
        from = Scale-Point -Point $From -ScaleKind $ScaleKind
        to = Scale-Point -Point $To -ScaleKind $ScaleKind
        uv_offset = @([int]$Uv[0], [int]$Uv[1])
    }
}

$templatePath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\templates\entities\$Template.json"))
$templateDef = Read-Utf8Json -Path $templatePath
$elements = @()

foreach ($part in $templateDef.parts) {
    if ($part.PSObject.Properties["optional"] -and -not $ArmorPlates) {
        continue
    }
    $scaleKind = "body"
    if ($part.PSObject.Properties["scale"] -and $part.scale) {
        $scaleKind = $part.scale
    }
    $elements += New-CubeElement -Name $part.name -From @($part.from) -To @($part.to) -Uv @($part.uv) -ScaleKind $scaleKind
}

if ($Horns) {
    $elements += New-CubeElement -Name "left_horn" -From @(-5, 30, -4) -To @(-3, 36, -2) -Uv @(48, 0) -ScaleKind "head"
    $elements += New-CubeElement -Name "right_horn" -From @(3, 30, -4) -To @(5, 36, -2) -Uv @(56, 0) -ScaleKind "head"
}
if ($Spikes) {
    $elements += New-CubeElement -Name "back_spikes" -From @(-2, 20, 5) -To @(2, 31, 7) -Uv @(48, 8) -ScaleKind "body"
}
if ($Wings) {
    $elements += New-CubeElement -Name "left_wing" -From @(5, 13, 2) -To @(15, 27, 3) -Uv @(32, 32) -ScaleKind "body"
    $elements += New-CubeElement -Name "right_wing" -From @(-15, 13, 2) -To @(-5, 27, 3) -Uv @(32, 48) -ScaleKind "body"
}
if ($Tail) {
    $elements += New-CubeElement -Name "tail" -From @(-1.5, 8, 9) -To @(1.5, 14, 18) -Uv @(48, 16) -ScaleKind "limb"
}
if ($ArmorPlates) {
    $elements += New-CubeElement -Name "chest_plate" -From @(-6, 18, -7) -To @(6, 29, -6) -Uv @(32, 0) -ScaleKind "body"
}

$textureWidth = [int]$templateDef.texture.width
$textureHeight = [int]$templateDef.texture.height
Add-Type -AssemblyName System.Drawing
$textureBitmap = [System.Drawing.Bitmap]::new($textureWidth, $textureHeight, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$memory = [System.IO.MemoryStream]::new()
try {
    for ($y = 0; $y -lt $textureHeight; $y++) {
        for ($x = 0; $x -lt $textureWidth; $x++) {
            $shade = 60 + (($x + $y) % 48)
            $textureBitmap.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $shade, $shade, $shade))
        }
    }
    $textureBitmap.Save($memory, [System.Drawing.Imaging.ImageFormat]::Png)
    $embeddedPng = [Convert]::ToBase64String($memory.ToArray())
} finally {
    $memory.Dispose()
    $textureBitmap.Dispose()
}
$bbmodel = [ordered]@{
    meta = [ordered]@{ format_version = "5.0"; model_format = "bedrock" }
    name = $EntityName
    resolution = [ordered]@{ width = $textureWidth; height = $textureHeight }
    textures = @([ordered]@{
        name = $EntityName
        id = "0"
        width = $textureWidth
        height = $textureHeight
        source = "data:image/png;base64,$embeddedPng"
    })
    elements = $elements
    animations = @($templateDef.animations | ForEach-Object { [ordered]@{ name = $_; length = 1.0; loop = $true } })
}

$modelsDir = Resolve-ModFactoryPath -ProjectDir $ProjectDir -RelativePath "models"
if (-not (Test-Path $modelsDir)) {
    New-Item -ItemType Directory -Path $modelsDir | Out-Null
}

$bbmodelRel = "models/$EntityName.bbmodel.json"
$bbmodelPath = Resolve-ModFactoryPath -ProjectDir $ProjectDir -RelativePath $bbmodelRel
Write-Utf8Json -Path $bbmodelPath -Value $bbmodel

$contract = [ordered]@{
    schemaVersion = 1
    entityId = "$ModId`:$EntityName"
    displayName = ($EntityName -replace "_", " ")
    reference = [ordered]@{ source = "template:$Template"; bbmodelPath = $bbmodelRel }
    texture = [ordered]@{
        path = "src/main/resources/assets/$ModId/textures/entity/$EntityName.png"
        width = [int]$templateDef.texture.width
        height = [int]$templateDef.texture.height
        source = "generated-template"
    }
    model = [ordered]@{
        javaPath = ""
        textureWidth = [int]$templateDef.texture.width
        textureHeight = [int]$templateDef.texture.height
        parts = @($elements | ForEach-Object { $_.name })
    }
    renderer = [ordered]@{
        javaPath = ""
        textureIdentifier = "$ModId`:textures/entity/$EntityName.png"
    }
    runtime = [ordered]@{
        entityTypeField = ($EntityName -replace "[^a-zA-Z0-9]+", "_").Trim("_").ToUpperInvariant()
        dimensions = [ordered]@{ width = [double]$templateDef.dimensions.width; height = [double]$templateDef.dimensions.height }
        spawnEgg = "$ModId`:${EntityName}_spawn_egg"
        bossBar = $false
    }
    loot = [ordered]@{ noDrop = $true }
    animations = @($templateDef.animations)
}

$contractRel = "models/$EntityName.contract.json"
$contractPath = Resolve-ModFactoryPath -ProjectDir $ProjectDir -RelativePath $contractRel
Write-Utf8Json -Path $contractPath -Value $contract

$langPath = Resolve-ModFactoryPath -ProjectDir $ProjectDir -RelativePath "src/main/resources/assets/$ModId/lang/en_us.json"
Ensure-ParentDirectory -Path $langPath
$lang = [ordered]@{
    "entity.$ModId.$EntityName" = ($EntityName -replace "_", " ")
    "item.$ModId.${EntityName}_spawn_egg" = "$(($EntityName -replace "_", " ")) Spawn Egg"
}
Write-Utf8Json -Path $langPath -Value $lang

$spawnItemPath = Resolve-ModFactoryPath -ProjectDir $ProjectDir -RelativePath "src/main/resources/assets/$ModId/items/${EntityName}_spawn_egg.json"
Ensure-ParentDirectory -Path $spawnItemPath
Write-Utf8Json -Path $spawnItemPath -Value ([ordered]@{
    model = [ordered]@{
        type = "minecraft:model"
        model = "$ModId`:item/${EntityName}_spawn_egg"
    }
})

$spawnModelPath = Resolve-ModFactoryPath -ProjectDir $ProjectDir -RelativePath "src/main/resources/assets/$ModId/models/item/${EntityName}_spawn_egg.json"
Ensure-ParentDirectory -Path $spawnModelPath
Write-Utf8Json -Path $spawnModelPath -Value ([ordered]@{
    parent = "minecraft:item/template_spawn_egg"
})

Write-Host "GENERATED template=$Template bbmodel=$bbmodelRel contract=$contractRel parts=$($elements.Count)"
