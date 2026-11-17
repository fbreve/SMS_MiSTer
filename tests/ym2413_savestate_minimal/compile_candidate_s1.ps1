$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path "$PSScriptRoot/../..").Path
$toolRoot = 'C:/intelFPGA_lite/17.0/quartus/bin64'

if (Test-Path X:/) {
    & subst.exe X: /d
}

# Map X: directly to the repo root
& subst.exe X: $repoRoot
if ($LASTEXITCODE) {
    throw "Failed to map X: to $repoRoot"
}

try {
    Write-Host "=================================================="
    Write-Host "Compiling final candidate RBF using Seed 1..."
    Write-Host "=================================================="

    # Ensure SEED 1 in SMS.qsf
    $qsf = Get-Content "$repoRoot/SMS.qsf"
    $qsf = $qsf -replace 'set_global_assignment -name SEED \d+', 'set_global_assignment -name SEED 1'
    $qsf | Set-Content "$repoRoot/SMS.qsf"

    # Clean previous build artifacts
    foreach ($item in @('db', 'incremental_db', 'output_files')) {
        if (Test-Path "$repoRoot/$item") {
            Remove-Item -Recurse -Force "$repoRoot/$item"
        }
    }

    Push-Location X:/
    try {
        Write-Host "Running quartus_map..."
        & "$toolRoot/quartus_map.exe" SMS --parallel=4
        if ($LASTEXITCODE) { throw "quartus_map failed" }

        Write-Host "Running quartus_fit..."
        & "$toolRoot/quartus_fit.exe" SMS --parallel=4
        if ($LASTEXITCODE) { throw "quartus_fit failed" }

        Write-Host "Running quartus_asm..."
        & "$toolRoot/quartus_asm.exe" SMS
        if ($LASTEXITCODE) { throw "quartus_asm failed" }

        Write-Host "Running quartus_sta..."
        & "$toolRoot/quartus_sta.exe" SMS
        if ($LASTEXITCODE) { throw "quartus_sta failed" }
    } finally {
        Pop-Location
    }

    if (Test-Path "$repoRoot/output_files/SMS.rbf") {
        Copy-Item "$repoRoot/output_files/SMS.rbf" "$repoRoot/SMS_ym2413_test_s1.rbf" -Force
        Write-Host "SUCCESS: Generated $repoRoot/SMS_ym2413_test_s1.rbf"
    } else {
        throw "SMS.rbf not found after assembly!"
    }
} finally {
    & subst.exe X: /d
}
