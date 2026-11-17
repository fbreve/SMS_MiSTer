foreach($o in 950,1100,1300){foreach($i in 0,1){ & "$PSScriptRoot/integrated.ps1" -Program 28 -Offset $o -IntCase $i; if($LASTEXITCODE -ne 0){exit 1}}}
& "$PSScriptRoot/integrated.ps1" -Program 31 -Offset 1000 -IntCase 5
