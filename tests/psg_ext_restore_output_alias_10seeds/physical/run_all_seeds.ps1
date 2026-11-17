$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
$toolRoot = 'C:/intelFPGA_lite/17.0/quartus/bin64'

if (Test-Path X:/) {
    & subst.exe X: /d
}

$running = Get-Process quartus_map, quartus_fit, quartus_asm, quartus_sta -ErrorAction SilentlyContinue | Where-Object { -not $_.HasExited }
if ($running) {
    throw "An external Quartus compilation process is currently active."
}

# Map X: directly to the repo root
& subst.exe X: $repoRoot
if ($LASTEXITCODE) {
    throw "Failed to map X: to $repoRoot"
}

try {
    # 10 paired seeds: Seeds 1 to 10
    $seeds = 1..10

    # Ensure runs directory exists
    $runsDir = "$PSScriptRoot/runs"
    if (-not (Test-Path $runsDir)) {
        New-Item -ItemType Directory -Force -Path $runsDir | Out-Null
    }

    # Pre-copy baseline builds from video_state experiment because candidate of video_state is the EXACT baseline of psg_ext!
    foreach ($seed in 1..10) {
        $vidCandDir = "$repoRoot/tests/video_state_restore_output_alias_10seeds/physical/runs/candidate_s$seed"
        $targetBase  = "$runsDir/baseline_s$seed"
        if ((Test-Path "$vidCandDir/output_files/SMS.fit.rpt") -and (-not (Test-Path "$targetBase/output_files/SMS.fit.rpt"))) {
            Write-Host "Reusing exact matching baseline build for Seed $seed from video_state experiment (candidate_s$seed)."
            New-Item -ItemType Directory -Force -Path $targetBase | Out-Null
            Copy-Item "$vidCandDir/*" "$targetBase/" -Recurse -Force
        }
    }

    foreach ($seed in $seeds) {
        $runs = @(
            @{ Name = "baseline_s$seed";  Seed = $seed; Candidate = $false },
            @{ Name = "candidate_s$seed"; Seed = $seed; Candidate = $true  }
        )

        foreach ($run in $runs) {
            $runName = $run.Name
            $isCand  = $run.Candidate
            $destDir = "$runsDir/$runName"

            # Check if this build already exists and is complete
            if ((Test-Path "$destDir/output_files/SMS.fit.rpt") -and (Test-Path "$destDir/output_files/SMS.sta.rpt")) {
                Write-Host "[$runName] Already completed. Skipping..."
                continue
            }

            Write-Host "=================================================="
            Write-Host "Starting build for $runName (Seed $seed, Candidate=$isCand)"
            Write-Host "=================================================="

            # Clean old build artifacts in root if any
            foreach ($item in @('db', 'incremental_db', 'output_files')) {
                if (Test-Path "$repoRoot/$item") {
                    Remove-Item -Recurse -Force "$repoRoot/$item"
                }
            }

            # Set SEED in SMS.qsf
            $qsf = Get-Content "$repoRoot/SMS.qsf"
            $qsf = $qsf -replace 'set_global_assignment -name SEED \d+', "set_global_assignment -name SEED $seed"
            $qsf | Set-Content "$repoRoot/SMS.qsf"

            # Set savestates.sv to baseline or candidate
            if ($isCand) {
                Copy-Item "$PSScriptRoot/savestates_candidate.sv" "$repoRoot/rtl/savestates.sv" -Force
            } else {
                Copy-Item "$PSScriptRoot/savestates_baseline.sv" "$repoRoot/rtl/savestates.sv" -Force
            }

            # Run synthesis and fitting using X: drive
            Push-Location X:/
            try {
                Write-Host "[$runName] Running quartus_map..."
                & "$toolRoot/quartus_map.exe" SMS --parallel=4
                if ($LASTEXITCODE) { throw "quartus_map failed on $runName" }

                Write-Host "[$runName] Running quartus_fit..."
                & "$toolRoot/quartus_fit.exe" SMS --parallel=4
                if ($LASTEXITCODE) { throw "quartus_fit failed on $runName" }

                Write-Host "[$runName] Running quartus_asm..."
                & "$toolRoot/quartus_asm.exe" SMS
                if ($LASTEXITCODE) { throw "quartus_asm failed on $runName" }

                Write-Host "[$runName] Running quartus_sta..."
                & "$toolRoot/quartus_sta.exe" SMS
                if ($LASTEXITCODE) { throw "quartus_sta failed on $runName" }
            } finally {
                Pop-Location
            }

            # Archive results
            if (Test-Path $destDir) { Remove-Item -Recurse -Force $destDir }
            New-Item -ItemType Directory -Force -Path "$destDir/output_files" | Out-Null
            Copy-Item "$repoRoot/output_files/SMS.fit.rpt" "$destDir/output_files/" -Force
            Copy-Item "$repoRoot/output_files/SMS.map.rpt" "$destDir/output_files/" -Force
            Copy-Item "$repoRoot/output_files/SMS.sta.rpt" "$destDir/output_files/" -Force
            Copy-Item "$repoRoot/output_files/SMS.flow.rpt" "$destDir/output_files/" -Force
            if (Test-Path "$repoRoot/output_files/SMS.rbf") {
                Copy-Item "$repoRoot/output_files/SMS.rbf" "$destDir/output_files/" -Force
            }

            Write-Host "[$runName] Build successfully archived in $destDir"
        }
    }
} finally {
    & subst.exe X: /d
    # Restore candidate to rtl/savestates.sv and clean SMS.qsf
    Copy-Item "$PSScriptRoot/savestates_candidate.sv" "$repoRoot/rtl/savestates.sv" -Force
    $qsf = Get-Content "$repoRoot/SMS.qsf"
    $qsf = $qsf -replace 'set_global_assignment -name SEED \d+', "set_global_assignment -name SEED 1"
    $qsf | Set-Content "$repoRoot/SMS.qsf"
}

