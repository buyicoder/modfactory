Set-StrictMode -Version Latest

function Get-TextureVariantPreset {
    param([Parameter(Mandatory=$true)][string]$Name)

    $presets = @{
        "dark-forged" = @{ tint = @(42, 36, 35); accent = @(239, 126, 44); strength = 0.55; accentRate = 17; material = "metal" }
        "frost"       = @{ tint = @(126, 188, 214); accent = @(212, 246, 255); strength = 0.45; accentRate = 19; material = "stone" }
        "lava"        = @{ tint = @(91, 37, 24); accent = @(255, 92, 20); strength = 0.50; accentRate = 13; material = "stone" }
        "storm"       = @{ tint = @(62, 68, 91); accent = @(120, 182, 255); strength = 0.42; accentRate = 23; material = "metal" }
        "ancient"     = @{ tint = @(107, 96, 67); accent = @(102, 171, 111); strength = 0.38; accentRate = 29; material = "stone" }
        "corrupted"   = @{ tint = @(75, 36, 91); accent = @(176, 44, 206); strength = 0.48; accentRate = 11; material = "organic" }
    }

    if (-not $presets.ContainsKey($Name)) {
        throw "Unknown texture variant preset '$Name'. Expected one of: $($presets.Keys -join ', ')"
    }

    return $presets[$Name]
}

function Blend-Channel {
    param([int]$Source, [int]$Target, [double]$Amount)
    return [Math]::Max(0, [Math]::Min(255, [int][Math]::Round(($Source * (1.0 - $Amount)) + ($Target * $Amount))))
}

function Get-VariantNoise {
    param([int]$X, [int]$Y, [int]$Seed)
    $value = (($X * 73856093) -bxor ($Y * 19349663) -bxor ($Seed * 83492791)) -band 0x7fffffff
    return $value % 100
}

function Convert-PixelForVariant {
    param(
        [Parameter(Mandatory=$true)][System.Drawing.Color]$Color,
        [Parameter(Mandatory=$true)]$Preset,
        [int]$X,
        [int]$Y,
        [int]$Seed
    )

    if ($Color.A -eq 0) {
        return $Color
    }

    $noise = Get-VariantNoise -X $X -Y $Y -Seed $Seed
    $materialShift = 0
    switch ($Preset.material) {
        "metal" { $materialShift = if ((($X + $Y) % 3) -eq 0) { 10 } else { -6 } }
        "stone" { $materialShift = if ($noise -lt 35) { -12 } elseif ($noise -gt 85) { 14 } else { 0 } }
        "organic" { $materialShift = if ($noise -lt 45) { 8 } else { -8 } }
    }

    $amount = [double]$Preset.strength
    $r = Blend-Channel -Source ([Math]::Max(0, [Math]::Min(255, $Color.R + $materialShift))) -Target $Preset.tint[0] -Amount $amount
    $g = Blend-Channel -Source ([Math]::Max(0, [Math]::Min(255, $Color.G + $materialShift))) -Target $Preset.tint[1] -Amount $amount
    $b = Blend-Channel -Source ([Math]::Max(0, [Math]::Min(255, $Color.B + $materialShift))) -Target $Preset.tint[2] -Amount $amount

    $isAccent = (($X -eq $Y) -or ((($X * 3 + $Y * 5 + $Seed) % [int]$Preset.accentRate) -eq 0)) -and $noise -gt 58
    if ($isAccent) {
        $r = Blend-Channel -Source $r -Target $Preset.accent[0] -Amount 0.72
        $g = Blend-Channel -Source $g -Target $Preset.accent[1] -Amount 0.72
        $b = Blend-Channel -Source $b -Target $Preset.accent[2] -Amount 0.72
    }

    return [System.Drawing.Color]::FromArgb($Color.A, $r, $g, $b)
}

function Convert-TextureVariant {
    param(
        [Parameter(Mandatory=$true)][string]$SourcePng,
        [Parameter(Mandatory=$true)][string]$OutputPath,
        [Parameter(Mandatory=$true)][string]$Theme
    )

    Add-Type -AssemblyName System.Drawing
    $preset = Get-TextureVariantPreset -Name $Theme
    $source = [System.Drawing.Bitmap]::new($SourcePng)
    try {
        $output = [System.Drawing.Bitmap]::new($source.Width, $source.Height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        try {
            $seed = [Math]::Abs($Theme.GetHashCode())
            for ($y = 0; $y -lt $source.Height; $y++) {
                for ($x = 0; $x -lt $source.Width; $x++) {
                    $output.SetPixel($x, $y, (Convert-PixelForVariant -Color $source.GetPixel($x, $y) -Preset $preset -X $x -Y $y -Seed $seed))
                }
            }

            $parent = Split-Path -Parent $OutputPath
            if ($parent -and -not (Test-Path $parent)) {
                New-Item -ItemType Directory -Path $parent | Out-Null
            }
            $output.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
        } finally {
            $output.Dispose()
        }
    } finally {
        $source.Dispose()
    }
}
