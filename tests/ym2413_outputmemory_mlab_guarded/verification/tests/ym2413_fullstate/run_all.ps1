$ErrorActionPreference='Stop'
$sim='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe'
function Invoke-Simulation([string]$DoFile,[string]$Log,[string]$PassPattern){
 & $sim -c -wlf "$Log.wlf" -do $DoFile -l "$Log.log" *> "${Log}_stdout.log"
 $result=Get-Content "$Log.log" -Raw
 if($LASTEXITCODE -ne 0 -or $result -notmatch $PassPattern -or $result -match '\*\* (Fatal|Error|Failure):'){throw "Simulation failed: $Log"}
 Write-Output "PASS $Log"
}
Push-Location $PSScriptRoot
try {
 node verify_scope.js;if($LASTEXITCODE -ne 0){throw 'scope validation failed'}
 node prepare_tests.js;node prepare_nonfm.js;node prepare_phases.js;node prepare_patterns.js
 Invoke-Simulation compile.do compile 'Errors: 0|do compile.do'
 Invoke-Simulation fast_compile.do fast_compile 'Errors: 0|do fast_compile.do'
 Invoke-Simulation phase_compile.do phase_compile 'Errors: 0|do phase_compile.do'
 Invoke-Simulation map.do map 'PASS independent pattern ALL'
 Invoke-Simulation protocol.do protocol 'PASS protocol ALL'
 Invoke-Simulation nonfm.do nonfm 'PASS nonFM ALL'
 Invoke-Simulation phases.do phases 'PASS PHASE SWEEP ALL'
 Remove-Item Env:FAST -ErrorAction SilentlyContinue
 $env:MODE='0';$env:SHIFT='0'
 Invoke-Simulation run.do case0 'PASS fullstate'
 & "$PSScriptRoot/campaign.ps1"
 node results.js;if($LASTEXITCODE -ne 0){throw 'result validation failed'}
} finally {Pop-Location}
