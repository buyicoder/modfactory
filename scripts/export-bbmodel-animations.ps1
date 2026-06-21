param(
    [Parameter(Mandatory=$true)][string]$BbmodelPath,
    [Parameter(Mandatory=$true)][string]$ProjectDir,
    [Parameter(Mandatory=$true)][string]$EntityName,
    [Parameter(Mandatory=$true)][string]$BoneMapPath,
    [string]$ModId = "modid",
    [string[]]$ClipNames = @()
)

Set-StrictMode -Version Latest
. "$PSScriptRoot\lib\ModFactory.Path.ps1"

function Get-BbBoneNameMap {
    param($Bb)
    $map = @{}
    if ($Bb.PSObject.Properties["groups"]) {
        foreach ($group in @($Bb.groups)) {
            if ($group.uuid -and $group.name) {
                $map[$group.uuid] = [string]$group.name
            }
        }
    }
    return $map
}

function Get-MappedBoneName {
    param(
        [hashtable]$BoneMap,
        [string]$SourceBone
    )
    if ($BoneMap.ContainsKey($SourceBone)) {
        return [string]$BoneMap[$SourceBone]
    }
    return $SourceBone
}

function Add-ChannelKeyframe {
    param(
        [hashtable]$Tracks,
        [string]$Bone,
        [string]$Channel,
        [double]$Time,
        [double]$X,
        [double]$Y,
        [double]$Z
    )
    if (-not $Tracks.ContainsKey($Bone)) {
        $Tracks[$Bone] = @{}
    }
    if (-not $Tracks[$Bone].ContainsKey($Channel)) {
        $Tracks[$Bone][$Channel] = @()
    }
    $Tracks[$Bone][$Channel] += ,@{
        t = [Math]::Round($Time, 4)
        x = [Math]::Round($X, 4)
        y = [Math]::Round($Y, 4)
        z = [Math]::Round($Z, 4)
    }
}

function Convert-AnimationTracks {
    param(
        $Animators,
        [hashtable]$UuidToBone,
        [hashtable]$BoneMap
    )
    $tracks = @{}
    foreach ($animatorProp in $Animators.PSObject.Properties) {
        $animator = $animatorProp.Value
        $sourceBone = if ($animator.name) { [string]$animator.name } elseif ($UuidToBone.ContainsKey($animatorProp.Name)) { $UuidToBone[$animatorProp.Name] } else { $animatorProp.Name }
        $bone = Get-MappedBoneName -BoneMap $BoneMap -SourceBone $sourceBone
        if (-not $animator.PSObject.Properties["keyframes"]) { continue }
        foreach ($kf in @($animator.keyframes)) {
            $channel = [string]$kf.channel
            if ($channel -ne "rotation" -and $channel -ne "position") { continue }
            $point = $kf.data_points[0]
            $x = [double]$point.x
            $y = [double]$point.y
            $z = [double]$point.z
            Add-ChannelKeyframe -Tracks $tracks -Bone $bone -Channel $channel -Time ([double]$kf.time) -X $x -Y $y -Z $z
        }
    }

    $ordered = [ordered]@{}
    foreach ($bone in ($tracks.Keys | Sort-Object)) {
        $channels = [ordered]@{}
        foreach ($channel in ($tracks[$bone].Keys | Sort-Object)) {
            $frames = @($tracks[$bone][$channel] | Sort-Object { $_.t })
            $channels[$channel] = $frames
        }
        $ordered[$bone] = $channels
    }
    return $ordered
}

$bb = Read-Utf8Json -Path $BbmodelPath
$boneMapJson = Read-Utf8Json -Path $BoneMapPath
$boneMap = @{}
foreach ($entry in $boneMapJson.bones.PSObject.Properties) {
    $boneMap[$entry.Name] = [string]$entry.Value
}

$rotationMeta = [ordered]@{
    xSign = if ($boneMapJson.rotation.xSign) { [int]$boneMapJson.rotation.xSign } else { -1 }
    ySign = if ($boneMapJson.rotation.ySign) { [int]$boneMapJson.rotation.ySign } else { 1 }
    zSign = if ($boneMapJson.rotation.zSign) { [int]$boneMapJson.rotation.zSign } else { 1 }
}

$uuidToBone = Get-BbBoneNameMap -Bb $bb
if (-not $bb.PSObject.Properties["animations"]) {
    throw "No animations found in $BbmodelPath"
}

$exported = 0
foreach ($anim in @($bb.animations)) {
    $clipName = [string]$anim.name
    if ($ClipNames.Count -gt 0 -and ($ClipNames -notcontains $clipName)) {
        continue
    }

    $fileStem = ($clipName -replace "^animation\.", "" -replace "\.", "_")
    $outRel = "src/main/resources/assets/$ModId/animations/$EntityName/$fileStem.json"
    $outPath = Resolve-ModFactoryPath -ProjectDir $ProjectDir -RelativePath $outRel
    Ensure-ParentDirectory -Path $outPath

    $loop = $false
    if ($anim.loop -eq "loop" -or $anim.loop -eq $true) {
        $loop = $true
    }

    $clip = [ordered]@{
        schemaVersion = 1
        name          = $clipName
        lengthSeconds = [double]$anim.length
        loop          = $loop
        rotation      = $rotationMeta
        bones         = Convert-AnimationTracks -Animators $anim.animators -UuidToBone $uuidToBone -BoneMap $boneMap
    }

    Write-Utf8Json -Path $outPath -Value $clip
    $exported++
    Write-Host "EXPORTED clip=$clipName -> $outRel bones=$($clip.bones.Count)"
}

if ($exported -eq 0) {
    throw "No animation clips exported. Check -ClipNames filter."
}

Write-Host "DONE exported=$exported entity=$EntityName mod=$ModId"
