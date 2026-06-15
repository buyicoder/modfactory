param(
    [Parameter(Mandatory=$true)][string]$ContractPath,
    [string]$SchemaPath
)

Set-StrictMode -Version Latest

. "$PSScriptRoot\lib\ModFactory.Path.ps1"

function Get-DefaultSchemaPath {
    param([Parameter(Mandatory=$true)][string]$Path)

    $fileName = [System.IO.Path]::GetFileName($Path)
    $schemaName = switch -Regex ($fileName) {
        '(^|\.)entity\.contract\.json$' { 'entity.contract.schema.json'; break }
        '(^|\.)asset\.contract\.json$' { 'asset.contract.schema.json'; break }
        '(^|\.)animation\.contract\.json$' { 'animation.contract.schema.json'; break }
        '(^|\.)qa\.report\.json$' { 'qa.report.schema.json'; break }
        default { $null }
    }

    if (-not $schemaName) {
        throw "Cannot infer schema for contract file: $fileName. Pass -SchemaPath explicitly."
    }

    return Join-Path (Split-Path -Parent $PSScriptRoot) "schemas\contracts\$schemaName"
}

function Get-JsonTypeName {
    param($Value)

    if ($null -eq $Value) { return "null" }
    if ($Value -is [bool]) { return "boolean" }
    if ($Value -is [byte] -or $Value -is [int16] -or $Value -is [int32] -or $Value -is [int64]) { return "integer" }
    if ($Value -is [single] -or $Value -is [double] -or $Value -is [decimal]) { return "number" }
    if ($Value -is [string]) { return "string" }
    if ($Value -is [System.Array]) { return "array" }
    if ($Value -is [System.Collections.IEnumerable] -and $Value -isnot [string] -and $Value -isnot [pscustomobject]) { return "array" }
    if ($Value -is [pscustomobject]) { return "object" }
    return $Value.GetType().Name
}

function Test-JsonType {
    param(
        [Parameter(Mandatory=$true)]$Value,
        [Parameter(Mandatory=$true)][string]$ExpectedType
    )

    $actual = Get-JsonTypeName -Value $Value
    if ($ExpectedType -eq "number") {
        return $actual -eq "number" -or $actual -eq "integer"
    }
    return $actual -eq $ExpectedType
}

function Get-ArrayItems {
    param($Value)

    if ($Value -is [System.Array]) {
        return ,@($Value)
    }
    if ($Value -is [System.Collections.IEnumerable] -and $Value -isnot [string] -and $Value -isnot [pscustomobject]) {
        return ,@($Value)
    }
    return ,@()
}

function Test-ContractNode {
    param(
        [Parameter(Mandatory=$true)]$Value,
        [Parameter(Mandatory=$true)]$Schema,
        [Parameter(Mandatory=$true)][string]$Path
    )

    $errors = @()

    if ($Schema.PSObject.Properties["type"]) {
        if (-not (Test-JsonType -Value $Value -ExpectedType $Schema.type)) {
            return @("$Path expected $($Schema.type), got $(Get-JsonTypeName -Value $Value)")
        }
    }

    if ($Schema.PSObject.Properties["enum"]) {
        $allowed = @($Schema.enum)
        $matched = $false
        foreach ($item in $allowed) {
            if ($Value -eq $item) {
                $matched = $true
                break
            }
        }
        if (-not $matched) {
            $errors += "$Path must be one of: $($allowed -join ', ')"
        }
    }

    if ($Schema.PSObject.Properties["pattern"] -and $Value -is [string]) {
        if ($Value -notmatch $Schema.pattern) {
            $errors += "$Path does not match pattern $($Schema.pattern): $Value"
        }
    }

    if ($Schema.PSObject.Properties["minimum"] -and ($Value -is [byte] -or $Value -is [int16] -or $Value -is [int32] -or $Value -is [int64] -or $Value -is [single] -or $Value -is [double] -or $Value -is [decimal])) {
        if ($Value -lt $Schema.minimum) {
            $errors += "$Path must be >= $($Schema.minimum), got $Value"
        }
    }

    if ($Schema.PSObject.Properties["required"]) {
        foreach ($name in @($Schema.required)) {
            if (-not $Value.PSObject.Properties[$name]) {
                $errors += "$Path missing required field: $name"
            }
        }
    }

    if ($Schema.PSObject.Properties["properties"] -and $Value -is [pscustomobject]) {
        foreach ($prop in $Schema.properties.PSObject.Properties) {
            $name = $prop.Name
            if ($Value.PSObject.Properties[$name]) {
                $errors += Test-ContractNode -Value $Value.$name -Schema $prop.Value -Path "$Path.$name"
            }
        }
    }

    if ($Schema.PSObject.Properties["items"]) {
        $items = Get-ArrayItems -Value $Value
        for ($i = 0; $i -lt $items.Count; $i++) {
            $errors += Test-ContractNode -Value $items[$i] -Schema $Schema.items -Path "$Path[$i]"
        }
    }

    return $errors
}

if (-not (Test-Path $ContractPath)) {
    Write-Error "Contract not found: $ContractPath"
    exit 2
}

if (-not $SchemaPath) {
    $SchemaPath = Get-DefaultSchemaPath -Path $ContractPath
}

if (-not (Test-Path $SchemaPath)) {
    Write-Error "Schema not found: $SchemaPath"
    exit 2
}

$contract = Read-Utf8Json -Path $ContractPath
$schema = Read-Utf8Json -Path $SchemaPath
$errors = @(Test-ContractNode -Value $contract -Schema $schema -Path '$')

if ($errors.Count -gt 0) {
    Write-Host "FAIL contract validation: $ContractPath"
    foreach ($errorMessage in $errors) {
        Write-Host "  - $errorMessage"
    }
    exit 1
}

Write-Host "PASS contract validation: $ContractPath"
exit 0
