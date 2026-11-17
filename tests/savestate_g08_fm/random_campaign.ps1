param([int]$Worker=0,[int]$Workers=8)
$ErrorActionPreference='Stop'
for($i=$Worker;$i -lt 24;$i+=$Workers){
 $seed=101+$i;$phase=(($seed*1103515245L+12345)%2147483647)%72;$skew=$seed%2;$only=if($seed%5 -eq 0){0}else{$seed%2}
 $log=Join-Path $PSScriptRoot "random_capture_$seed/replay.log"
 if(Test-Path $log){$s=Get-Content $log -Raw;if($s -match 'PASS G08FM' -and $s -match 'PASS OPLL_READBACK load1 rows104' -and $s -match 'Errors: 0' -and $s -notmatch '\*\* (Error|Fatal|Failure):'){Write-Output "RETAIN PASS random_capture_$seed";continue}}
 & "$PSScriptRoot/known.ps1" -Phase $phase -Skew $skew -FMOnly $only -Stereo ([int]($only -eq 0)) -Program 1 -Seed $seed -Stall ($seed%3) -N 48000 -Replays 1 -CaseName "random_capture_$seed"
}
