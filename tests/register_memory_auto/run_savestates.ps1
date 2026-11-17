$ErrorActionPreference='Stop'
Push-Location $PSScriptRoot
try {
 foreach($taskCase in @(@{Do='savestate.do';Log='savestate.log';Ref=''},@{Do='savestate_gate.do';Log='savestate_gate_reference.log';Ref='1'},@{Do='savestate_gate.do';Log='savestate_gate.log';Ref='0'})) {
  if(Test-Path $taskCase.Log){throw 'Never overwrite a simulation attempt'}
  $env:GATE_REFERENCE=$taskCase.Ref
  & C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe -c -do $taskCase.Do -l $taskCase.Log *> ($taskCase.Log+'.console')
  if($LASTEXITCODE){throw ('Simulator failed '+$taskCase.Log)}
  $taskText=Get-Content $taskCase.Log -Raw
  if(($taskText -notmatch 'PASS ') -or ($taskText -match '\*\* (Fatal|Error):|# Errors: [1-9]|is not bound')){throw ('Simulation did not qualify '+$taskCase.Log)}
  Write-Output ('PASS '+$taskCase.Log)
 }
 & node functional_results.js
 if($LASTEXITCODE){throw 'Functional result validation failed'}
} finally {Remove-Item Env:GATE_REFERENCE -ErrorAction SilentlyContinue;Pop-Location}
