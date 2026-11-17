param([switch]$SkipPrepare)
$ErrorActionPreference='Stop'
[Diagnostics.Process]::GetCurrentProcess().PriorityClass=[Diagnostics.ProcessPriorityClass]::Idle
Set-Location $PSScriptRoot
$sim='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe'
if(Test-Path logs){throw 'Refuse overwriting regression logs'}
New-Item -ItemType Directory logs | Out-Null
function Check([string]$Do,[string]$Name,[string]$Pass){
 & $sim -c -wlf "logs/$Name.wlf" -do $Do -l "logs/$Name.log" *> "logs/$Name.console.log"
 $code=$LASTEXITCODE;$text=Get-Content "logs/$Name.log" -Raw
 if($code -or $text -notmatch $Pass -or $text -match '\*\* (Fatal|Error|Failure):'){throw "Regression failed $Name"}
 Write-Output "PASS $Name"
}
node verify_combined_scope.js;if($LASTEXITCODE){throw 'scope'}
if(!$SkipPrepare){foreach($p in @('prepare_nonfm.js','prepare_phases.js','prepare_patterns.js')){node $p;if($LASTEXITCODE){throw "prepare $p"}}}
Check compile.do compile 'Errors: 0|do compile.do'
Check fast_compile.do fast_compile 'Errors: 0|do fast_compile.do'
Check phase_compile.do phase_compile 'Errors: 0|do phase_compile.do'
Check map.do independent_map 'PASS independent pattern ALL'
Check protocol.do original_protocol 'PASS protocol ALL'
Check guard_protocol.do guard_protocol 'PASS guard atomic FM rejection'
Check nonfm.do nonfm 'PASS nonFM ALL'
Check phases.do phases 'PASS PHASE SWEEP ALL'
Check validator_stream.do actual_validator 'PASS ACTUAL_VALIDATOR accepted=6912 rejected=2 no_live_FM_writes'
Check early_validator.do early_validator 'PASS ACTUAL_VALIDATOR accepted=432 rejected=0 no_live_FM_writes'
Check guard_live.do live_rejection 'PASS LIVE_REJECTION case=1'
$env:MODE='0';$env:SHIFT='0';Remove-Item Env:FAST -ErrorAction SilentlyContinue
Check run.do fullstate_mode0 'PASS fullstate'
$env:FAST='1'
foreach($mode in 1..6){$env:MODE="$mode";$env:SHIFT="$(($mode*13)%72)";Check run.do "fullstate_mode$mode" 'PASS fullstate'}
Remove-Item Env:FAST -ErrorAction SilentlyContinue
Write-Output 'PASS INTEGRATED MODELSIM REGRESSIONS'
