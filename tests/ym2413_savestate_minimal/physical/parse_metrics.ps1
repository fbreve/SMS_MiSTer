param(
    [string]$RunDir
)

$res = [ordered]@{}

# Fit summary
$fitSummary = "$RunDir/output_files/SMS.fit.summary"
if (Test-Path $fitSummary) {
    $lines = Get-Content $fitSummary
    foreach ($line in $lines) {
        if ($line -match 'Logic utilization \(in ALMs\)\s*:\s*([\d,]+)\s*/\s*([\d,]+)\s*\(\s*(\d+)\s*%\s*\)') {
            $res['Placed_ALMs'] = [int]($Matches[1] -replace ',','')
        }
        if ($line -match 'Total registers\s*:\s*(\d+)') {
            $res['Total_Registers'] = [int]$Matches[1]
        }
        if ($line -match 'Total block memory bits\s*:\s*([\d,]+)') {
            $res['M10K_Bits'] = [int]($Matches[1] -replace ',','')
        }
        if ($line -match 'Total RAM Blocks\s*:\s*([\d,]+)') {
            $res['M10K_Blocks'] = [int]($Matches[1] -replace ',','')
        }
    }
}

# Fit report for detailed breakdown
$fitRpt = "$RunDir/output_files/SMS.fit.rpt"
if (Test-Path $fitRpt) {
    $rptText = Get-Content $fitRpt
    foreach ($l in $rptText) {
        if ($l -match ';\s*ALMs needed \[=A-B\+C\]\s*;\s*([\d,]+)\s*;') {
            if (-not $res.Contains('Needed_ALMs')) {
                $res['Needed_ALMs'] = [int]($Matches[1] -replace ',','')
            }
        }
        if ($l -match ';\s*Combinational ALUT usage for logic\s*;\s*([\d,]+)') {
            $res['Logic_ALUTs'] = [int]($Matches[1] -replace ',','')
        }
        if ($l -match ';\s*Combinational ALUT usage for route-throughs\s*;\s*([\d,]+)') {
            $res['Routing_ALUTs'] = [int]($Matches[1] -replace ',','')
        }
    }
}

# STA summary
$staSummary = "$RunDir/output_files/SMS.sta.summary"
if (Test-Path $staSummary) {
    $lines = Get-Content $staSummary
    $worstSetup = 999.0
    $worstHold = 999.0
    $totalTns = 0.0

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        if ($line -match "Type\s*:\s*Setup") {
            $slackLine = $lines[$i+1]
            if ($slackLine -match "Slack\s*:\s*([-\d\.]+)") {
                $val = [double]$Matches[1]
                if ($val -lt $worstSetup) { $worstSetup = $val }
            }
            $tnsLine = $lines[$i+2]
            if ($tnsLine -match "TNS\s*:\s*([-\d\.]+)") {
                $tnsVal = [double]$Matches[1]
                if ($tnsVal -lt 0) { $totalTns += $tnsVal }
            }
        }
        if ($line -match "Type\s*:\s*Hold") {
            $slackLine = $lines[$i+1]
            if ($slackLine -match "Slack\s*:\s*([-\d\.]+)") {
                $val = [double]$Matches[1]
                if ($val -lt $worstHold) { $worstHold = $val }
            }
        }
    }
    $res['Setup_Slack'] = $worstSetup
    $res['Hold_Slack']  = $worstHold
    $res['TNS']         = $totalTns
}

return [PSCustomObject]$res

