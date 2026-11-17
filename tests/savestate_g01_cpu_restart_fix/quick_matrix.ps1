param([int]$Worker=0)
$sets=@(@(10,719),@(11,719),@(12,600),@(13,600),@(14,816),@(15,816),@(16,600),@(26,600))
for($i=$Worker;$i -lt $sets.Count;$i+=2){$p=$sets[$i][0]; & "$PSScriptRoot/quick.ps1" -Program $p -Offset $sets[$i][1]; if($LASTEXITCODE -ne 0){exit 1}}
