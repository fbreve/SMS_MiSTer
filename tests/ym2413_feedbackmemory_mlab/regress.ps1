$ErrorActionPreference='Stop'
Set-Location "$PSScriptRoot/worktree/tests/ym2413_fullstate"
$taskSim='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe'
foreach($taskPrep in @('prepare_nonfm.js','prepare_phases.js','prepare_patterns.js')){node $taskPrep;if($LASTEXITCODE){throw "Preparation failed $taskPrep"}}
function Invoke-Check([string]$Do,[string]$Name,[string]$Pass){
 & $taskSim -c -wlf "logs/$Name.wlf" -do $Do -l "logs/$Name.log" *> "logs/$Name.console.log"
 $taskExit=$LASTEXITCODE;Set-Content "logs/$Name.exitcode" $taskExit
 $taskText=Get-Content "logs/$Name.log" -Raw
 if($taskExit -or $taskText -notmatch $Pass -or $taskText -match '\*\* (Fatal|Error|Failure):'){throw "Regression failed $Name"}
 Write-Output "PASS $Name"
}
Invoke-Check compile.do modelsim_compile 'Errors: 0|do compile.do'
Invoke-Check fast_compile.do modelsim_fast_compile 'Errors: 0|do fast_compile.do'
Invoke-Check phase_compile.do modelsim_phase_compile 'Errors: 0|do phase_compile.do'
Invoke-Check map.do independent_map 'PASS independent pattern ALL'
Invoke-Check protocol.do protocol 'PASS protocol ALL'
Invoke-Check nonfm.do nonfm 'PASS nonFM ALL'
Invoke-Check phases.do phases 'PASS PHASE SWEEP ALL'
$env:MODE='0';$env:SHIFT='0';Remove-Item Env:FAST -ErrorAction SilentlyContinue
Invoke-Check run.do fullstate_mode0 'PASS fullstate'
$env:FAST='1'
foreach($taskMode in 1..6){$env:MODE="$taskMode";$env:SHIFT="$(($taskMode*13)%72)";Invoke-Check run.do "fullstate_mode$taskMode" 'PASS fullstate'}
Remove-Item Env:FAST -ErrorAction SilentlyContinue
Write-Output 'PASS ALL FULLSTATE REGRESSIONS'
