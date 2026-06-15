param(
    [Parameter(Mandatory=$true)][string]$MinecraftClientJar,
    [Parameter(Mandatory=$true)][string]$VanillaTexture,
    [Parameter(Mandatory=$true)][string]$OutputPath,
    [ValidateSet("dark-iron","dark-iron-spawn-egg")]
    [string]$Palette = "dark-iron"
)

Set-StrictMode -Version Latest

if (-not (Test-Path $MinecraftClientJar)) {
    throw "Minecraft client jar not found: $MinecraftClientJar"
}

$entryName = "assets/minecraft/textures/item/$VanillaTexture.png"

Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.Drawing

function Clamp-Channel {
    param([double]$Value)
    return [Math]::Max(0, [Math]::Min(255, [int][Math]::Round($Value)))
}

function Convert-Color {
    param(
        [Parameter(Mandatory=$true)][System.Drawing.Color]$Color,
        [Parameter(Mandatory=$true)][string]$PaletteName
    )

    if ($Color.A -eq 0) {
        return $Color
    }

    $luma = (($Color.R * 0.299) + ($Color.G * 0.587) + ($Color.B * 0.114)) / 255.0
    $isWarmAccent = $Color.R -gt ($Color.G + 18) -and $Color.R -gt ($Color.B + 18)

    if ($PaletteName -eq "dark-iron-spawn-egg" -and $isWarmAccent) {
        $r = 80 + (120 * $luma)
        $g = 14 + (36 * $luma)
        $b = 18 + (30 * $luma)
    } else {
        $r = 28 + (90 * $luma)
        $g = 26 + (74 * $luma)
        $b = 28 + (76 * $luma)
    }

    return [System.Drawing.Color]::FromArgb(
        $Color.A,
        (Clamp-Channel $r),
        (Clamp-Channel $g),
        (Clamp-Channel $b)
    )
}

$zip = [System.IO.Compression.ZipFile]::OpenRead($MinecraftClientJar)
try {
    $entry = $zip.GetEntry($entryName)
    if ($null -eq $entry) {
        throw "Vanilla texture not found in jar: $entryName"
    }

    $stream = $entry.Open()
    try {
        $source = [System.Drawing.Bitmap]::new($stream)
        try {
            $output = [System.Drawing.Bitmap]::new($source.Width, $source.Height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
            try {
                for ($y = 0; $y -lt $source.Height; $y++) {
                    for ($x = 0; $x -lt $source.Width; $x++) {
                        $output.SetPixel($x, $y, (Convert-Color -Color $source.GetPixel($x, $y) -PaletteName $Palette))
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
    } finally {
        $stream.Dispose()
    }
} finally {
    $zip.Dispose()
}

Write-Host "DERIVED texture=$VanillaTexture palette=$Palette output=$OutputPath source=$entryName"
