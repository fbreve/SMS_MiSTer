$runs = @('baseline_s1', 'candidate_s1', 'baseline_s2', 'candidate_s2', 'baseline_s3', 'candidate_s3')
$list = @()
foreach ($r in $runs) {
    $p = Resolve-Path ("$PSScriptRoot/runs/" + $r)
    $m = & "$PSScriptRoot/parse_metrics.ps1" -RunDir $p
    $m | Add-Member -MemberType NoteProperty -Name 'Run' -Value $r
    $list += $m
}
$list | Select-Object Run, Placed_ALMs, Needed_ALMs, Total_Registers, Logic_ALUTs, Routing_ALUTs, M10K_Blocks, Setup_Slack, Hold_Slack, TNS | Format-Table -AutoSize

