$ErrorActionPreference='Stop'
$root=$PSScriptRoot
foreach($seed in 1,3){
 $d="$root/physical_seed$seed"
 & "$d/build.ps1" *> "$d/build_console.log"; if($LASTEXITCODE){throw "build seed $seed"}
 & "$d/query.ps1" *> "$d/query_console.log"; if($LASTEXITCODE){throw "query seed $seed"}
 Push-Location $d; node collect.js *> collection.log; $x=$LASTEXITCODE; Pop-Location; if($x){throw "collect seed $seed"}
 & powershell -NoProfile -ExecutionPolicy Bypass -File "$d/atoms.ps1" *> "$d/atoms_console.log"
 "seed $seed done $(Get-Date -Format o)" | Add-Content "$root/seeds13.log"
}
