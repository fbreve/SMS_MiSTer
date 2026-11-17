$ErrorActionPreference = 'Stop'
$physicalDir = $PSScriptRoot

$runs = @(
    @{ Seed = 1; Baseline = "baseline_s1"; Candidate = "candidate_s1" },
    @{ Seed = 2; Baseline = "baseline_s2"; Candidate = "candidate_s2" },
    @{ Seed = 3; Baseline = "baseline_s3"; Candidate = "candidate_s3" }
)

$results = @()

foreach ($pair in $runs) {
    $seed = $pair.Seed
    $baseDir = "$physicalDir/runs/$($pair.Baseline)"
    $candDir = "$physicalDir/runs/$($pair.Candidate)"

    if ((Test-Path "$baseDir/output_files/SMS.fit.summary") -and (Test-Path "$candDir/output_files/SMS.fit.summary")) {
        $baseMetrics = & "$physicalDir/parse_metrics.ps1" -RunDir $baseDir
        $candMetrics = & "$physicalDir/parse_metrics.ps1" -RunDir $candDir

        $results += [PSCustomObject]@{
            Seed             = $seed
            Base_Placed_ALMs = $baseMetrics.Placed_ALMs
            Cand_Placed_ALMs = $candMetrics.Placed_ALMs
            Delta_Placed     = $candMetrics.Placed_ALMs - $baseMetrics.Placed_ALMs
            Base_Needed_ALMs = $baseMetrics.Needed_ALMs
            Cand_Needed_ALMs = $candMetrics.Needed_ALMs
            Delta_Needed     = $candMetrics.Needed_ALMs - $baseMetrics.Needed_ALMs
            Base_Regs        = $baseMetrics.Total_Registers
            Cand_Regs        = $candMetrics.Total_Registers
            Delta_Regs       = $candMetrics.Total_Registers - $baseMetrics.Total_Registers
            Base_Logic_ALUTs = $baseMetrics.Logic_ALUTs
            Cand_Logic_ALUTs = $candMetrics.Logic_ALUTs
            Delta_Logic_ALUT = $candMetrics.Logic_ALUTs - $baseMetrics.Logic_ALUTs
            Base_Route_ALUTs = $baseMetrics.Routing_ALUTs
            Cand_Route_ALUTs = $candMetrics.Routing_ALUTs
            Delta_Route_ALUT = $candMetrics.Routing_ALUTs - $baseMetrics.Routing_ALUTs
            Base_Setup       = $baseMetrics.Setup_Slack
            Cand_Setup       = $candMetrics.Setup_Slack
            Base_Hold        = $baseMetrics.Hold_Slack
            Cand_Hold        = $candMetrics.Hold_Slack
            Cand_TNS         = $candMetrics.TNS
        }
    }
}

$results | Format-Table -AutoSize
