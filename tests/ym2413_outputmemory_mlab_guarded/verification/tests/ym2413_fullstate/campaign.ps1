param([int[]]$Modes=@(1,2,3,4,5,6))
$ErrorActionPreference='Stop'
$sim='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe'
Push-Location $PSScriptRoot
try {
 $env:FAST='1'
 foreach($caseMode in $Modes){
  $env:MODE="$caseMode";$env:SHIFT="$(($caseMode*13)%72)"
  & $sim -c -wlf "mode${caseMode}.wlf" -do run.do -l "mode${caseMode}.log" *> "mode${caseMode}_stdout.log"
  $result=Get-Content "mode${caseMode}.log" -Raw
  if($LASTEXITCODE -ne 0 -or $result -notmatch 'PASS fullstate' -or $result -match '\*\* (Fatal|Error|Failure):'){throw "FM mode $caseMode failed"}
  if(@(Select-String 'PASS independent internal oracle' "mode${caseMode}.log").Count -ne 9){throw "incomplete oracle mode $caseMode"}
  Write-Output "PASS fullstate mode=$caseMode"
 }
} finally {Remove-Item Env:FAST -ErrorAction SilentlyContinue;Pop-Location}
