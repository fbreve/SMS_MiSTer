$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
$toolRoot = 'C:/intelFPGA_lite/17.0/quartus/bin64'

if (Test-Path X:/) {
    & subst.exe X: /d
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
    # 3 paired seeds: Seed 1, Seed 2, Seed 3
    $seeds = @(1, 2, 3)

    foreach ($seed in $seeds) {
        $runs = @(
            @{ Name = "baseline_s$seed";  Seed = $seed; Candidate = $false },
            @{ Name = "candidate_s$seed"; Seed = $seed; Candidate = $true  }
        )

        foreach ($run in $runs) {
            $runName = $run.Name
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
            $destDir = "$PSScriptRoot/runs/$runName"
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
    # Restore candidate to rtl/savestates.sv
    Copy-Item "$PSScriptRoot/savestates_candidate.sv" "$repoRoot/rtl/savestates.sv" -Force
}

