$ErrorActionPreference='Stop'
Push-Location $PSScriptRoot
try{
 & 'C:/Program Files/nodejs/node.exe' pre_fix_prepare.js
 foreach($case in 1,3,4,7,8){
  $env:PAUSE_CASE="$case";$env:PAUSE_KEEP='0';$env:PAUSE_FULL='0'
  [IO.File]::WriteAllText("$PSScriptRoot/red_case$case.do",(Get-Content -Raw red_run.do).Replace('pause_work',"red_case${case}_work"))
  & 'C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe' -c -do "red_case$case.do" *> "red_case$case.log"
  $code=$LASTEXITCODE;$s=Get-Content -Raw "red_case$case.log"
  if($code -ne 0 -or $s -match '\*\* (Error|Fatal|Failure)' -or $s -notmatch 'PASS case'){throw "Pre-fix reproduction failed case $case"}
  Write-Output "REPRODUCED pre-fix case $case"
 }
}finally{Pop-Location}
