param([int]$Worker=0)
$sets=@(@(11,0),@(12,0),@(13,0),@(14,0),@(15,0),@(16,0),@(26,0),@(17,0),@(18,0),@(19,0),@(20,0),@(21,0),@(22,0),@(23,0),@(24,0),@(25,0))
for($i=$Worker;$i -lt $sets.Count;$i+=2){$p=$sets[$i][0]; & "$PSScriptRoot/fast.ps1" -Program $p -Offset $sets[$i][1]; if($LASTEXITCODE -ne 0){exit 1}}
