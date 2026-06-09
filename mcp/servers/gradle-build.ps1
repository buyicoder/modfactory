# Gradle Build MCP Server
# Executes gradle commands, parses build output for errors

param(
    [string]$Action = "build",
    [string]$ProjectDir = "",
    [string]$JavaHome = ""
)

if ($ProjectDir -eq "") {
    Write-Error "ProjectDir is required"
    exit 1
}

if ($JavaHome -eq "") {
    $JavaHome = $env:JAVA_HOME
}

$env:JAVA_HOME = $JavaHome
$env:PATH = "$JavaHome\bin;$env:PATH"

Set-Location $ProjectDir

function Run-Build {
    Write-Output @{ status = "building" } | ConvertTo-Json
    $output = & ./gradlew build 2>&1
    $exitCode = $LASTEXITCODE

    $errors = @()
    $warnings = @()

    foreach ($line in $output) {
        # Parse error patterns
        if ($line -match "error:|错误:") {
            $errors += @{
                file = ($line -replace '.*?(\\w+\\.java):.*', '$1')
                line = ($line -replace '.*?:(\d+):.*', '$1')
                message = $line
            }
        }
        if ($line -match "warning:|警告:") {
            $warnings += $line
        }
    }

    Write-Output @{
        status = if ($exitCode -eq 0) { "SUCCESS" } else { "FAILED" }
        exitCode = $exitCode
        errorCount = $errors.Count
        warningCount = $warnings.Count
        errors = $errors | Select-Object -First 10
        warnings = $warnings | Select-Object -First 5
        fullOutput = ($output -join "`n")
    } | ConvertTo-Json -Depth 3
}

function Run-Client {
    $output = & ./gradlew runClient 2>&1
    $exitCode = $LASTEXITCODE
    Write-Output @{
        status = if ($exitCode -eq 0) { "RUNNING" } else { "FAILED" }
        exitCode = $exitCode
    } | ConvertTo-Json
}

function Parse-Errors {
    param($BuildOutput)
    $errors = @()
    foreach ($line in ($BuildOutput -split "`n")) {
        if ($line -match "(错误|error):") {
            # Extract error code pattern for auto-fix lookup
            $pattern = ""
            if ($line -match "程序包.*不存在|package.*does not exist") {
                $pattern = "package_not_found"
            } elseif ($line -match "找不到符号|cannot find symbol") {
                $pattern = "symbol_not_found"
            } elseif ($line -match "Item\.Factory") {
                $pattern = "item_factory"
            } elseif ($line -match "TypedActionResult") {
                $pattern = "typed_action_result"
            } elseif ($line -match "isClient.*private") {
                $pattern = "isclient_private"
            }

            $errors += @{
                pattern = $pattern
                file = ($line -replace '.*?(\\w+\\.java).*', '$1')
                message = $line
                confidence = if ($pattern) { 90 } else { 0 }
            }
        }
    }
    Write-Output $errors | ConvertTo-Json -Depth 2
}

# Main
switch ($Action) {
    "build" { Run-Build }
    "run" { Run-Client }
    "parse" { Parse-Errors -BuildOutput $ProjectDir }
}
