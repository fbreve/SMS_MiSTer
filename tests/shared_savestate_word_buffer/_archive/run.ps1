$ErrorActionPreference='Stop'
Push-Location (Resolve-Path "$PSScriptRoot/../..")
try {
 & node tests/shared_savestate_word_buffer/prepare.js
 if($LASTEXITCODE){throw 'prepare failed'}
 & node tests/shared_savestate_word_buffer/prepare_focused.js
 if($LASTEXITCODE){throw 'focused prepare failed'}
 & node tests/shared_savestate_word_buffer/prepare_targeted.js
 if($LASTEXITCODE){throw 'targeted prepare failed'}
} finally {Pop-Location}
Push-Location $PSScriptRoot
try {
 foreach($case in @('existing','focused','targeted')) {
  $commands=if($case -eq 'existing') {'onerror {quit -code 1}; onbreak {quit -code 1}; vlib work; vlog -sv -quiet controller_baseline.sv controller_candidate.sv existing_tb.sv; vsim -c -t 1ps work.savestate_tb; run -all; quit -code 0'}else{"do $case.do"}
  & C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe -c -do $commands -l "$case.recheck.log"
  if($LASTEXITCODE){throw "Simulator failed: $case"}
  $result=Get-Content "$case.recheck.log" -Raw
  if($result -notmatch '# PASS ' -or $result -match '\*\* (Error|Fatal):|Errors: [1-9]'){throw "Unqualified: $case"}
 }
} finally {Pop-Location}
