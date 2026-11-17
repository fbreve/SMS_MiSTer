param([int]$Worker=0,[int]$Workers=12)
$ErrorActionPreference='Stop'
for($i=$Worker;$i -lt 144;$i+=$Workers){
 $phase=[int][Math]::Floor($i/2);$skew=$i%2;$fmOnly=if($phase%2){0}else{1}
 $stall=($phase+$skew)%3
 $case="sweep_p$($phase)_s$skew"
 $log=Join-Path $PSScriptRoot "$case/replay.log"
 if(Test-Path $log){$s=Get-Content $log -Raw;if($s -match 'PASS G08FM' -and $s -match 'PASS OPLL_READBACK load1 rows104' -and $s -match 'Errors: 0' -and $s -notmatch '\*\* (Error|Fatal|Failure):'){Write-Output "RETAIN PASS $case";continue}}
 & "$PSScriptRoot/known.ps1" -Variant candidate -Phase $phase -Skew $skew -FMOnly $fmOnly -Stall $stall -N 6000 -Replays 1 -Stereo ([int]($fmOnly -eq 0)) -CaseName $case
}
