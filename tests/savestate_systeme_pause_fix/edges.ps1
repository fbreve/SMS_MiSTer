param([int]$Group=0)
$ErrorActionPreference='Stop'
$jobs=@()
foreach($offset in 0..5){$jobs+=,@(10,$offset)}
foreach($offset in 0..3){$jobs+=,@(18,$offset)}
foreach($offset in 0..1){$jobs+=,@(11,$offset)}
$jobs+=,@(14,0);$jobs+=,@(15,0)
for($j=0;$j -lt $jobs.Count;$j++){if($j%2 -eq $Group){& "$PSScriptRoot/fixed.ps1" -Cases $jobs[$j][0] -Offset $jobs[$j][1]}}
