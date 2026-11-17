foreach($p in 10,11,12,13,14,15,16,26){ & "$PSScriptRoot/proof.ps1" -Program $p -Captures 120; if($LASTEXITCODE -ne 0){exit 1}}
