$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
$toolRoot = 'C:/intelFPGA_lite/17.0/quartus/bin64'

if (Test-Path X:/) {
    throw "Drive X: is occupied. Cannot proceed with subst."
}

$running = Get-Process quartus_map, quartus_fit, quartus_asm, quartus_sh -ErrorAction SilentlyContinue
if ($running) {
    throw "An external Quartus compilation process is currently active."
}

# Map X: directly to the repo root
& subst.exe X: $repoRoot
if ($LASTEXITCODE) {
    throw "Failed to map X: to $repoRoot"
}

try {
    $runs = @(
        @{ Name = "baseline_s1";  Seed = 1; Candidate = $false },
        @{ Name = "candidate_s1"; Seed = 1; Candidate = $true  },
        @{ Name = "baseline_s2";  Seed = 2; Candidate = $false },
        @{ Name = "candidate_s2"; Seed = 2; Candidate = $true  }
    )

    foreach ($run in $runs) {
        $runName = $run.Name
        $seed    = $run.Seed
        $isCand  = $run.Candidate

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
            Copy-Item "$PSScriptRoot/../savestates_candidate.sv" "$repoRoot/rtl/savestates.sv"
        } else {
            Copy-Item "$PSScriptRoot/../savestates_upstream.sv" "$repoRoot/rtl/savestates.sv"
        }

        # Destination folder for logs and reports
        $outDir = "$PSScriptRoot/runs/$runName"
        New-Item -ItemType Directory -Force -Path $outDir | Out-Null

        Push-Location "X:/"
        try {
            foreach ($stage in @('map', 'fit', 'sta')) {
                Write-Host "Running quartus_$stage on $runName..."
                $sw = [System.Diagnostics.Stopwatch]::StartNew()
                if ($stage -eq 'sta') {
                    & "$toolRoot/quartus_$stage.exe" "SMS" *> "$outDir/$stage.log"
                } else {
                    & "$toolRoot/quartus_$stage.exe" --read_settings_files=on --write_settings_files=off "SMS" *> "$outDir/$stage.log"
                }
                $exitCode = $LASTEXITCODE
                $sw.Stop()
                Write-Host "$runName $stage finished in $($sw.Elapsed.TotalSeconds)s (ExitCode: $exitCode)"
                if ($exitCode -ne 0) {
                    throw "Build failed for $runName during quartus_$stage (ExitCode: $exitCode)"
                }
            }

            # Save summaries and reports
            if (Test-Path "output_files") {
                Copy-Item -Recurse -Force "output_files" "$outDir/output_files"
            }
        } finally {
            Pop-Location
        }
    }
} finally {
    # Restore candidate rtl in working tree
    Copy-Item "$PSScriptRoot/../savestates_candidate.sv" "$repoRoot/rtl/savestates.sv"
    
    # Restore seed 1 in SMS.qsf
    $qsf = Get-Content "$repoRoot/SMS.qsf"
    $qsf = $qsf -replace 'set_global_assignment -name SEED \d+', "set_global_assignment -name SEED 1"
    $qsf | Set-Content "$repoRoot/SMS.qsf"

    if (Test-Path X:/) {
        & subst.exe X: /D
    }
}

