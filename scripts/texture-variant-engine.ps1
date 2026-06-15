param(
    [Parameter(Mandatory=$true)][string]$SourcePng,
    [Parameter(Mandatory=$true)][string]$OutputPath,
    [ValidateSet("dark-forged","frost","lava","storm","ancient","corrupted")]
    [string]$Theme = "dark-forged",
    [string]$ContractPath = ""
)

Set-StrictMode -Version Latest
. "$PSScriptRoot\lib\TextureVariant.ps1"

if (-not (Test-Path $SourcePng)) {
    throw "Source PNG not found: $SourcePng"
}

Add-Type -AssemblyName System.Drawing
$sourceImage = [System.Drawing.Bitmap]::new($SourcePng)
try {
    $sourceWidth = $sourceImage.Width
    $sourceHeight = $sourceImage.Height
    $alpha = New-Object int[] ($sourceWidth * $sourceHeight)
    for ($y = 0; $y -lt $sourceHeight; $y++) {
        for ($x = 0; $x -lt $sourceWidth; $x++) {
            $alpha[($y * $sourceWidth) + $x] = $sourceImage.GetPixel($x, $y).A
        }
    }
} finally {
    $sourceImage.Dispose()
}

if ($ContractPath) {
    . "$PSScriptRoot\lib\EntityContract.ps1"
    $contract = Read-EntityContract -Path $ContractPath
    $shapeErrors = @(Test-EntityContractShape -Contract $contract)
    if ($shapeErrors.Count -gt 0) {
        throw "Invalid contract: $($shapeErrors -join '; ')"
    }
    if ([int]$contract.texture.width -ne $sourceWidth -or [int]$contract.texture.height -ne $sourceHeight) {
        throw "Source PNG size $sourceWidth x $sourceHeight does not match contract texture $($contract.texture.width) x $($contract.texture.height)"
    }
}

Convert-TextureVariant -SourcePng $SourcePng -OutputPath $OutputPath -Theme $Theme

$outputImage = [System.Drawing.Bitmap]::new($OutputPath)
try {
    if ($outputImage.Width -ne $sourceWidth -or $outputImage.Height -ne $sourceHeight) {
        throw "Variant dimensions changed: source=$sourceWidth x $sourceHeight output=$($outputImage.Width) x $($outputImage.Height)"
    }
    for ($y = 0; $y -lt $sourceHeight; $y++) {
        for ($x = 0; $x -lt $sourceWidth; $x++) {
            $expectedAlpha = $alpha[($y * $sourceWidth) + $x]
            $actualAlpha = $outputImage.GetPixel($x, $y).A
            if ($actualAlpha -ne $expectedAlpha) {
                throw "Variant alpha changed at ${x},${y}: source=$expectedAlpha output=$actualAlpha"
            }
        }
    }
} finally {
    $outputImage.Dispose()
}

Write-Host "VARIANT theme=$Theme source=$SourcePng output=$OutputPath size=${sourceWidth}x${sourceHeight} alpha=preserved"
