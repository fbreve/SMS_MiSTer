param([string]$Vsim = $env:VSIM_EXE, [string]$Attempt = '')
$ErrorActionPreference='Stop'
if(-not $Vsim) { $Vsim=(Get-Command vsim.exe -ErrorAction Stop).Source }
if(-not $Attempt) { $Attempt=Join-Path $PSScriptRoot ('simulations/run-'+(Get-Date -Format 'yyyyMMdd-HHmmss')) }
if(Test-Path $Attempt) { throw 'Never overwrite a simulation attempt' }
$taskAttempt=[IO.Path]::GetFullPath($Attempt)
foreach($taskPrepare in @('prepare.js','prepare_focused.js','prepare_targeted.js')) {
 & node (Join-Path $PSScriptRoot $taskPrepare) $taskAttempt
 if($LASTEXITCODE) { throw "Preparation failed: $taskPrepare" }
}
Push-Location $taskAttempt
try {
 foreach($taskCase in @('existing','focused','targeted')) {
  $taskCommands=if($taskCase -eq 'existing') {'onerror {quit -code 1}; onbreak {quit -code 1}; vlib work; vlog -sv -quiet controller_baseline.sv controller_candidate.sv existing_tb.sv; vsim -c -t 1ps work.savestate_tb; run -all; quit -code 0'}else{"do $taskCase.do"}
  & $Vsim -c -do $taskCommands -l "$taskCase.log" *> "$taskCase.console"
  if($LASTEXITCODE) { throw "Simulator failed: $taskCase" }
  $taskLog=Get-Content "$taskCase.log" -Raw
  if($taskLog -notmatch '# PASS ' -or $taskLog -match '\*\* (Error|Fatal):|Errors: [1-9]|is not bound') { throw "Unqualified: $taskCase" }
  Write-Output "PASS $taskCase"
 }
 & node (Join-Path $PSScriptRoot 'verify.js') $taskAttempt
 if($LASTEXITCODE) { throw 'Verification failed' }
} finally { Pop-Location }
