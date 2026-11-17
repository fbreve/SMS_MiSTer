$ErrorActionPreference='Stop'
Push-Location $PSScriptRoot
try {
 & 'C:/Program Files/nodejs/node.exe' prepare.js
 foreach($case in 0..11){
  $env:F13_CASE="$case"
  & 'C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe' -c -do run.do *> "case$case.log"
  $code=$LASTEXITCODE;$s=Get-Content -Raw "case$case.log"
  if($code -ne 0 -or $s -match '\*\* (Error|Fatal|Failure)|Errors: [1-9]' -or $s -notmatch 'PASS F13'){Get-Content "case$case.log" -Tail 16;throw "Failed case $case"}
  Write-Output "PASS F13 case$case"
 }
}finally{Pop-Location}
