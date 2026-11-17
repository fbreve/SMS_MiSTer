param([int]$Worker=0,[int]$Workers=2)
$items=@(10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26)
for($i=$Worker;$i -lt $items.Count;$i+=$Workers){$log="$PSScriptRoot/integrated_p$($items[$i])_o0_t15_s0_c120_sig0_i0.log";if((Test-Path $log) -and (Get-Content -Raw $log) -match "PASS G01 CAPTURE_SWEEP"){continue}; & "$PSScriptRoot/integrated.ps1" -Program $items[$i] -Captures 120; if($LASTEXITCODE -ne 0){exit 1}}

