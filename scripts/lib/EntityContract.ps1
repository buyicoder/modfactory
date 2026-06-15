Set-StrictMode -Version Latest
. "$PSScriptRoot\ModFactory.Path.ps1"

function Read-EntityContract {
    param([Parameter(Mandatory=$true)][string]$Path)
    return Read-Utf8Json -Path $Path
}

function Test-EntityContractShape {
    param([Parameter(Mandatory=$true)]$Contract)
    $errors = @()
    foreach ($name in @("schemaVersion","entityId","texture","model","renderer","runtime","animations")) {
        if (-not $Contract.PSObject.Properties[$name]) {
            $errors += "Missing contract field: $name"
        }
    }
    if ($Contract.schemaVersion -ne 1) {
        $errors += "Unsupported schemaVersion: $($Contract.schemaVersion)"
    }
    if ($Contract.entityId -notmatch "^[a-z0-9_.-]+:[a-z0-9_./-]+$") {
        $errors += "Invalid entityId: $($Contract.entityId)"
    }
    foreach ($name in @("path","width","height")) {
        if (-not $Contract.texture.PSObject.Properties[$name]) {
            $errors += "Missing contract texture field: $name"
        }
    }
    foreach ($name in @("textureIdentifier")) {
        if (-not $Contract.renderer.PSObject.Properties[$name]) {
            $errors += "Missing contract renderer field: $name"
        }
    }
    foreach ($name in @("entityTypeField","dimensions","spawnEgg")) {
        if (-not $Contract.runtime.PSObject.Properties[$name]) {
            $errors += "Missing contract runtime field: $name"
        }
    }
    if ($Contract.texture.width -le 0 -or $Contract.texture.height -le 0) {
        $errors += "Texture width/height must be positive"
    }
    if ($Contract.model.textureWidth -ne $Contract.texture.width -or
        $Contract.model.textureHeight -ne $Contract.texture.height) {
        $errors += "Model texture size does not match texture dimensions"
    }
    if ($errors.Count -eq 0) {
        return @()
    }
    return $errors
}

function Split-NamespacedId {
    param([Parameter(Mandatory=$true)][string]$Id)
    $parts = $Id.Split(":", 2)
    if ($parts.Count -ne 2) {
        throw "Expected namespaced id, got: $Id"
    }
    return [ordered]@{ namespace = $parts[0]; path = $parts[1] }
}

function Convert-PathToFieldName {
    param([Parameter(Mandatory=$true)][string]$Path)
    return ($Path -replace "[^a-zA-Z0-9]+", "_").Trim("_").ToUpperInvariant()
}

function Get-EntityResourcePathsFromContract {
    param([Parameter(Mandatory=$true)]$Contract)
    $entityId = Split-NamespacedId -Id $Contract.entityId
    $modId = $entityId.namespace
    $entityPath = $entityId.path
    $spawnEgg = $null
    if ($Contract.runtime.PSObject.Properties["spawnEgg"] -and $Contract.runtime.spawnEgg) {
        $spawnEgg = Split-NamespacedId -Id $Contract.runtime.spawnEgg
    }

    $paths = [ordered]@{
        modId = $modId
        entityPath = $entityPath
        entityLangKey = "entity.$modId.$entityPath"
        langFile = "src/main/resources/assets/$modId/lang/en_us.json"
        lootTable = "src/main/resources/data/$modId/loot_table/entities/$entityPath.json"
        texture = $Contract.texture.path
        modelJava = $Contract.model.javaPath
        rendererJava = $Contract.renderer.javaPath
        entityTypeField = $Contract.runtime.entityTypeField
    }

    if ($spawnEgg) {
        $paths.spawnEggId = $Contract.runtime.spawnEgg
        $paths.spawnEggPath = $spawnEgg.path
        $paths.spawnEggField = Convert-PathToFieldName -Path $spawnEgg.path
        $paths.spawnEggLangKey = "item.$($spawnEgg.namespace).$($spawnEgg.path)"
        $paths.spawnEggItem = "src/main/resources/assets/$($spawnEgg.namespace)/items/$($spawnEgg.path).json"
        $paths.spawnEggModel = "src/main/resources/assets/$($spawnEgg.namespace)/models/item/$($spawnEgg.path).json"
    }

    return $paths
}
