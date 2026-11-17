foreach($p in 18,19,20,21,22,23,24,25){ & "$PSScriptRoot/integrated.ps1" -Program $p -Offset 40496; if($LASTEXITCODE -ne 0){exit 1}}
