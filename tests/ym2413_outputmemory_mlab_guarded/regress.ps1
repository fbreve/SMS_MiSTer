param([switch]$StreamOnly,[switch]$LiveOnly,[switch]$EarlyOnly)
$ErrorActionPreference='Stop'
[Diagnostics.Process]::GetCurrentProcess().PriorityClass=[Diagnostics.ProcessPriorityClass]::Idle
Set-Location "$PSScriptRoot/verification/tests/ym2413_fullstate"
$taskSim='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe'
function Check([string]$Do,[string]$Name,[string]$Pass){
 & $taskSim -c -wlf "logs/$Name.wlf" -do $Do -l "logs/$Name.log" *> "logs/$Name.console.log"
 $taskExit=$LASTEXITCODE;$taskText=Get-Content "logs/$Name.log" -Raw
 if($taskExit -or $taskText -notmatch $Pass -or $taskText -match '\*\* (Fatal|Error|Failure):'){throw "Regression failed $Name"}
 Write-Output "PASS $Name"
}
if($EarlyOnly){Check early_validator.do early_validator 'PASS ACTUAL_VALIDATOR accepted=432 rejected=0 no_live_FM_writes';exit 0}
if($LiveOnly){Check guard_live.do live_rejection 'PASS LIVE_REJECTION case=1';Write-Output 'PASS LIVE FM REJECTION';exit 0}
if(!$StreamOnly){
 Check compile.do compile 'Errors: 0|do compile.do'
 Check fast_compile.do fast_compile 'Errors: 0|do fast_compile.do'
 Check phase_compile.do phase_compile 'Errors: 0|do phase_compile.do'
 Check map.do independent_map 'PASS independent pattern ALL'
 Check protocol.do original_protocol 'PASS protocol ALL'
 Check guard_protocol.do guard_protocol 'PASS guard atomic FM rejection'
 Check nonfm.do nonfm 'PASS nonFM ALL'
 Check phases.do phases 'PASS PHASE SWEEP ALL'
 $env:MODE='0';$env:SHIFT='0';Remove-Item Env:FAST -ErrorAction SilentlyContinue
 Check run.do fullstate_mode0 'PASS fullstate'
 $env:FAST='1'
 foreach($taskMode in 1..6){$env:MODE="$taskMode";$env:SHIFT="$(($taskMode*13)%72)";Check run.do "fullstate_mode$taskMode" 'PASS fullstate'}
 Remove-Item Env:FAST -ErrorAction SilentlyContinue
}
Check validator_stream.do actual_validator 'PASS ACTUAL_VALIDATOR accepted=6912 rejected=2 no_live_FM_writes'
Write-Output 'PASS GUARDED FULLSTATE REGRESSIONS'
