param([int]$Group=0)
$ErrorActionPreference='Stop'
foreach($k in 0..13){if($k%2 -eq $Group){& "$PSScriptRoot/fixed.ps1" -Cases 16 -Delay (6+10*$k)}}
