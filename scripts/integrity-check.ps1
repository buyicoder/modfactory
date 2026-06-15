# ModFactory Integrity Checker
# Scans project for missing connections between registrations and resources

param([string]$ProjectDir = ".")

$errors = @()
$warnings = @()
$passes = @()

$entityContractLib = Join-Path $PSScriptRoot "lib\EntityContract.ps1"
if (Test-Path $entityContractLib) {
    . $entityContractLib
}

# ============================================================
# Scanning functions
# ============================================================

function Find-JavaFiles($pattern) {
    Get-ChildItem -Path $ProjectDir -Recurse -Filter "*.java" -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch "\\build\\" } |
        Select-String $pattern -List
}

function Find-RegisteredItems {
    $items = @()
    $files = Get-ChildItem -Path $ProjectDir -Recurse -Filter "ModItems.java" -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch "\\build\\" }
    foreach ($f in $files) {
        $content = Get-Content $f.FullName -Raw
        # Extract: public static final Item NAME = register("name", ...
        $matches = [regex]::Matches($content, 'register\("([^"]+)"')
        foreach ($m in $matches) {
            $name = $m.Groups[1].Value
            $line = ($content -split "`n" | Select-String "register.`"$name`"" | Select-Object -First 1).Line
            # Detect type: armor/tool/food/material
            $type = "material"
            if ($line -match "EquipmentType\.") { $type = "armor" }
            elseif ($line -match "\.sword\(|\.pickaxe\(|AxeItem|ShovelItem|HoeItem") { $type = "tool" }
            elseif ($line -match "FoodComponent|\.food\(") { $type = "food" }
            elseif ($name -match "_spawn_egg$" -or $line -match "SpawnEggItem|ModSpawnEggItem") { $type = "spawn_egg" }
            elseif ($line -match "LightningRubyItem|extends Item") { $type = "special" }
            $items += @{ name = $name; type = $type }
        }
    }
    return @($items)
}

function Find-ModIds {
    $ids = @()
    $resources = Join-Path $ProjectDir "src/main/resources/assets"
    if (Test-Path $resources) {
        Get-ChildItem -Path $resources -Directory -ErrorAction SilentlyContinue |
            ForEach-Object { $ids += $_.Name }
    }
    if ($ids.Count -eq 0) {
        $ids += "modid"
    }
    return @($ids | Select-Object -Unique)
}

function Find-RegisteredEntities {
    $entities = @()
    $files = Get-ChildItem -Path $ProjectDir -Recurse -Filter "ModEntityTypes.java" -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch "\\build\\" }
    foreach ($f in $files) {
        $content = Get-Content $f.FullName -Raw
        $fieldMatches = [regex]::Matches($content, 'public\s+static\s+final\s+EntityType<[^>]+>\s+([A-Z0-9_]+)')
        foreach ($m in $fieldMatches) {
            $field = $m.Groups[1].Value
            $path = ($field.ToLowerInvariant())
            $windowStart = [Math]::Max(0, $m.Index - 250)
            $windowLength = [Math]::Min($content.Length - $windowStart, 1000)
            $window = $content.Substring($windowStart, $windowLength)
            $pathMatch = [regex]::Match($window, 'Identifier\.of\([^,]+,\s*"([^"]+)"\)|register\("([^"]+)"')
            if ($pathMatch.Success) {
                if ($pathMatch.Groups[1].Value) {
                    $path = $pathMatch.Groups[1].Value
                } elseif ($pathMatch.Groups[2].Value) {
                    $path = $pathMatch.Groups[2].Value
                }
            }
            $entities += @{ field = $field; path = $path; file = $f.FullName }
        }
    }
    return @($entities)
}

function Get-EntityContractIndex {
    $index = @{}
    $contracts = Get-ChildItem -Path $ProjectDir -Recurse -Filter "*.contract.json" -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch "\\build\\" }
    foreach ($contractFile in $contracts) {
        try {
            $contract = Read-EntityContract -Path $contractFile.FullName
            if ($contract.entityId) {
                $index[$contract.entityId] = $contractFile.FullName
            }
            if ($contract.runtime.spawnEgg) {
                $index[$contract.runtime.spawnEgg] = $contractFile.FullName
            }
        } catch {
            $script:errors += "ENTITY_CONTRACT_UNREADABLE: $($contractFile.FullName) ($($_.Exception.Message))"
        }
    }
    return $index
}

function Find-RegisteredBlocks {
    $blocks = @()
    $files = Get-ChildItem -Path $ProjectDir -Recurse -Filter "ModBlocks.java" -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch "\\build\\" }
    foreach ($f in $files) {
        $content = Get-Content $f.FullName -Raw
        $matches = [regex]::Matches($content, 'register\("([^"]+)"')
        foreach ($m in $matches) {
            $blocks += @{ name = $m.Groups[1].Value }
        }
    }
    return @($blocks)
}

function Find-MixinClasses {
    $mixins = @()
    $files = Get-ChildItem -Path $ProjectDir -Recurse -Filter "*.java" -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch "\\build\\" }
    foreach ($f in $files) {
        $content = Get-Content $f.FullName -Raw
        if ($content -match "@Mixin") {
            $className = $f.BaseName
            $mixins += @{ name = $className; file = $f.FullName }
        }
    }
    return @($mixins)
}

function Test-FileExists($relativePath) {
    $fullPath = Join-Path $ProjectDir "src/main/resources/$relativePath"
    return Test-Path $fullPath
}

function Test-AnyFileExists($pattern) {
    $files = Get-ChildItem -Path "$ProjectDir/src/main/resources" -Recurse -Filter "*.json" -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch "\\build\\" }
    # Search in recipe files for item ID
    foreach ($f in $files) {
        $content = Get-Content $f.FullName -Raw -ErrorAction SilentlyContinue
        if ($content -match $pattern) { return $true }
    }
    return $false
}

# ============================================================
# Check Rules
# ============================================================

function Check-Item($item) {
    $id = $item.name
    $type = $item.type
    $prefix = if ($type -eq "armor" -or $type -eq "tool") { "ruby_" } else { "" }

    if ($type -eq "spawn_egg") {
        $modIds = Find-ModIds
        $hasItemMapping = $false
        $hasModel = $false
        foreach ($modId in $modIds) {
            if (Test-FileExists "assets/$modId/items/${id}.json") { $hasItemMapping = $true }
            if (Test-FileExists "assets/$modId/models/item/${id}.json") { $hasModel = $true }
        }
        if ($hasItemMapping) {
            $script:passes += "spawn_egg_item_mapping: $id"
        } else {
            $script:errors += "MISSING_SPAWN_EGG_ITEM_MAPPING: assets/<modid>/items/${id}.json"
        }
        if ($hasModel) {
            $script:passes += "spawn_egg_model: $id"
        } else {
            $script:errors += "MISSING_SPAWN_EGG_MODEL: assets/<modid>/models/item/${id}.json"
        }
        return
    }

    # Rule 1: Texture
    if (Test-FileExists "assets/modid/textures/item/${id}.png") {
        $script:passes += "texture: $id"
    } else {
        $script:errors += "MISSING: assets/modid/textures/item/${id}.png"
    }

    # Rule 1b: Model
    if (Test-FileExists "assets/modid/models/item/${id}.json") {
        $script:passes += "model: $id"
    } else {
        $script:errors += "MISSING: assets/modid/models/item/${id}.json"
    }

    # Rule 2: Creative tab (check ExampleMod.java)
    $mainMod = Get-ChildItem -Path $ProjectDir -Recurse -Filter "ExampleMod.java" -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch "\\build\\" } | Select-Object -First 1
    if ($mainMod) {
        $content = Get-Content $mainMod.FullName -Raw
        if ($content -match [regex]::Escape("ModItems.$($id.ToUpper())") -or
            $content -match [regex]::Escape("ModBlocks.$($id.ToUpper())")) {
            $script:passes += "tab: $id"
        } else {
            $script:warnings += "NOT_IN_TAB: $id (not added to creative inventory)"
        }
    }

    # Rule 3: Recipe
    if (Test-AnyFileExists "modid:$id") {
        $script:passes += "recipe: $id"
    } else {
        if ($type -ne "special") {
            $script:warnings += "NO_RECIPE: $id (no crafting recipe found)"
        }
    }

    # Rule 4/6: Armor equipment
    if ($type -eq "armor") {
        # Extract armor material name (everything before _helmet/_chestplate/etc.)
        $matName = $id -replace '_(helmet|chestplate|leggings|boots)$', ''
        if (Test-FileExists "assets/modid/equipment/${matName}.json") {
            $script:passes += "equipment_json: $id"
        } else {
            $script:errors += "MISSING: assets/modid/equipment/${matName}.json"
        }
        if (Test-FileExists "assets/modid/textures/entity/equipment/humanoid/${matName}.png") {
            $script:passes += "equipment_humanoid: $id"
        } else {
            $script:errors += "MISSING: textures/entity/equipment/humanoid/${matName}.png"
        }
        if (Test-FileExists "assets/modid/textures/entity/equipment/humanoid_leggings/${matName}.png") {
            $script:passes += "equipment_leggings: $id"
        } else {
            $script:errors += "MISSING: textures/entity/equipment/humanoid_leggings/${matName}.png"
        }
    }

    # Rule 7: Tool tags
    if ($type -eq "tool") {
        $toolTypes = @()
        if ($id -match "sword") { $toolTypes += "swords" }
        if ($id -match "pickaxe") { $toolTypes += "pickaxes" }
        if ($id -match "_axe\b|^axe\b") { $toolTypes += "axes" }
        if ($id -match "shovel") { $toolTypes += "shovels" }
        if ($id -match "hoe") { $toolTypes += "hoes" }

        foreach ($tt in $toolTypes) {
            if (Test-AnyFileExists "modid:${id}") {
                # Check if in the right tag file
                $tagFile = "$ProjectDir/src/main/resources/data/minecraft/tags/item/${tt}.json"
                if (Test-Path $tagFile) {
                    $tagContent = Get-Content $tagFile -Raw
                    if ($tagContent -match [regex]::Escape("modid:${id}")) {
                        $script:passes += "tag_${tt}: $id"
                    } else {
                        $script:errors += "MISSING_TAG: $id not in ${tt}.json"
                    }
                } else {
                    $script:errors += "MISSING_TAG_FILE: data/minecraft/tags/item/${tt}.json"
                }
            }
        }
    }
}

function Check-Block($block) {
    $id = $block.name

    # Block texture
    if (Test-FileExists "assets/modid/textures/block/${id}.png") {
        $script:passes += "block_texture: $id"
    } else {
        $script:errors += "MISSING: assets/modid/textures/block/${id}.png"
    }

    # Block model
    if (Test-FileExists "assets/modid/models/block/${id}.json") {
        $script:passes += "block_model: $id"
    } else {
        $script:errors += "MISSING: assets/modid/models/block/${id}.json"
    }

    # Blockstate
    if (Test-FileExists "assets/modid/blockstates/${id}.json") {
        $script:passes += "blockstate: $id"
    } else {
        $script:errors += "MISSING: assets/modid/blockstates/${id}.json"
    }

    # Item model for block
    if (Test-FileExists "assets/modid/models/item/${id}.json") {
        $script:passes += "block_item_model: $id"
    } else {
        $script:errors += "MISSING: assets/modid/models/item/${id}.json"
    }

    # Recipe for block
    if (Test-AnyFileExists "modid:${id}") {
        $script:passes += "block_recipe: $id"
    } else {
        $script:warnings += "NO_RECIPE: block $id"
    }
}

function Check-Mixins {
    $mixins = Find-MixinClasses
    $configFiles = Get-ChildItem -Path $ProjectDir -Recurse -Filter "*.mixins.json" -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch "\\build\\" }

    foreach ($m in $mixins) {
        $found = $false
        foreach ($cf in $configFiles) {
            $content = Get-Content $cf.FullName -Raw
            if ($content -match [regex]::Escape($m.name)) {
                $found = $true
                $script:passes += "mixin_config: $($m.name)"
                break
            }
        }
        if (-not $found) {
            $script:errors += "MISSING_MIXIN: $($m.name) not in any .mixins.json"
        }
    }

    # Also check: fabric.mod.json references mixin config
    $fabricMod = "$ProjectDir/src/main/resources/fabric.mod.json"
    if (Test-Path $fabricMod) {
        $fmContent = Get-Content $fabricMod -Raw
        foreach ($cf in $configFiles) {
            $configName = $cf.Name
            if ($fmContent -notmatch [regex]::Escape($configName)) {
                $script:errors += "MISSING_FABRIC_MOD_MIXIN: $configName not referenced in fabric.mod.json"
            } else {
                $script:passes += "fabric_mod_mixin: $configName"
            }
        }
    }
}

function Check-EntityContracts {
    $contracts = Get-ChildItem -Path $ProjectDir -Recurse -Filter "*.contract.json" -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch "\\build\\" }
    foreach ($contract in $contracts) {
        $validator = Join-Path $PSScriptRoot "validate-entity-assets.ps1"
        if (Test-Path $validator) {
            & powershell -NoProfile -ExecutionPolicy Bypass -File $validator -ProjectDir $ProjectDir -ContractPath $contract.FullName
            if ($LASTEXITCODE -eq 0) {
                $script:passes += "entity-contract: $($contract.Name)"
            } else {
                $script:errors += "ENTITY_CONTRACT_FAILED: $($contract.FullName)"
            }
        }
    }
}

function Check-RegisteredEntityClosure {
    $contracts = Get-EntityContractIndex
    $modIds = Find-ModIds
    $entities = Find-RegisteredEntities
    foreach ($entity in $entities) {
        $foundContract = $false
        foreach ($modId in $modIds) {
            $entityId = "${modId}:$($entity.path)"
            if ($contracts.ContainsKey($entityId)) {
                $foundContract = $true
                $script:passes += "entity-contract-present: $entityId"
                break
            }
        }
        if (-not $foundContract) {
            $script:errors += "MISSING_ENTITY_CONTRACT: $($entity.field) ($($entity.path))"
        }
    }

    $spawnEggs = @(Find-RegisteredItems) | Where-Object { $_.type -eq "spawn_egg" }
    foreach ($egg in $spawnEggs) {
        $foundContract = $false
        foreach ($modId in $modIds) {
            $eggId = "${modId}:$($egg.name)"
            if ($contracts.ContainsKey($eggId)) {
                $foundContract = $true
                $script:passes += "spawn-egg-contract-present: $eggId"
                break
            }
        }
        if (-not $foundContract) {
            $script:errors += "MISSING_SPAWN_EGG_CONTRACT: $($egg.name)"
        }
    }
}

# ============================================================
# Main
# ============================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " ModFactory Integrity Checker" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$items = @(Find-RegisteredItems)
$blocks = @(Find-RegisteredBlocks)

Write-Host "Found: $($items.Count) items, $($blocks.Count) blocks"
Write-Host ""

# Check items
foreach ($item in $items) {
    Check-Item $item
}

# Check blocks
foreach ($block in $blocks) {
    Check-Block $block
}

# Check mixins
Check-Mixins

# Check entity asset contracts
Check-EntityContracts

# Check registered entities and spawn eggs even without contracts
Check-RegisteredEntityClosure

# ============================================================
# Report
# ============================================================

Write-Host "--- RESULTS ---" -ForegroundColor Yellow
Write-Host ""

$errorCount = $errors.Count
$warnCount = $warnings.Count
$passCount = $passes.Count
$total = $errorCount + $warnCount + $passCount
$score = if ($total -gt 0) { [int]($passCount * 100 / $total) } else { 100 }

Write-Host "PASSES ($passCount):" -ForegroundColor Green
if ($passCount -gt 20) {
    Write-Host "  (${passCount} checks passed - all good)" -ForegroundColor Green
} else {
    foreach ($p in $passes) { Write-Host "  [PASS] $p" -ForegroundColor Green }
}

Write-Host ""
Write-Host "WARNINGS ($warnCount):" -ForegroundColor Yellow
foreach ($w in $warnings) { Write-Host "  [WARN] $w" -ForegroundColor Yellow }

Write-Host ""
Write-Host "FAILURES ($errorCount):" -ForegroundColor Red
foreach ($e in $errors) { Write-Host "  [FAIL] $e" -ForegroundColor Red }

Write-Host ""
Write-Host "========================================"
Write-Host " Score: $score% ($passCount/$total)" -ForegroundColor $(if ($score -ge 90) { "Green" } elseif ($score -ge 70) { "Yellow" } else { "Red" })
Write-Host "========================================"

# Return non-zero exit code if there are failures (for CI/CD)
if ($errorCount -gt 0) { exit 1 } else { exit 0 }
