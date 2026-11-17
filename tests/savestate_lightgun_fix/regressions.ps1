param([string]$Group)
$ErrorActionPreference='Stop'
$root=Resolve-Path "$PSScriptRoot/../.."
$sim='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe'
function Run-Sim([string]$Folder,[string]$Do,[string]$Label) {
 Push-Location "$root/tests/$Folder"
 try {
  $out="$PSScriptRoot/$Label.log"
  & $sim -c -do $Do *> $out
  $code=$LASTEXITCODE;$s=Get-Content -Raw $out
  if($code -ne 0 -or $s -match '\*\* (Error|Fatal|Failure)|Errors: [1-9]' -or $s -notmatch 'PASS') {Get-Content $out -Tail 20;throw "Failed $Label"}
  Write-Output "PASS $Label"
 } finally {Pop-Location}
}
switch($Group){
 f07 {$env:HCOUNTER_FIXED='true';$env:HCOUNTER_GG='0';Run-Sim savestate_hcounter vdp.do f07_sms;$env:HCOUNTER_GG='1';Run-Sim savestate_hcounter vdp.do f07_gg;Run-Sim savestate_hcounter controller.do f07_controller;Run-Sim savestate_hcounter integration.do f07_integration}
 f08 {Run-Sim savestate_md6 f10_replay.do f08_short;Run-Sim savestate_md6 f10_real.do f08_real;Run-Sim savestate_md6 integration.do f08_ddr}
 f09 {$env:TAP_TIMEOUT='8';Run-Sim savestate_master_tap replay.do f09_short;$env:TAP_TIMEOUT='57000';Run-Sim savestate_master_tap replay.do f09_real;Run-Sim savestate_master_tap ordinary.do f09_ordinary;$env:TAP_STALL='0';$env:TAP_CASE='-1';Run-Sim savestate_master_tap integration.do f09_ddr}
 f10 {Run-Sim savestate_paddle directed.do f10_directed;Run-Sim savestate_paddle replay.do f10_phases;Run-Sim savestate_paddle modes.do f10_modes;Run-Sim savestate_paddle ordinary.do f10_ordinary;$env:PADDLE_CASE='-1';Run-Sim savestate_paddle stalls0.do f10_ddr}
 f02 {$env:GG_FIXED='true';Run-Sim savestate_gg_io gg.do f02_direct;foreach($stall in 0,1){$env:DDRAM_STALLS="$stall";Run-Sim savestate_gg_io integration.do "f02_ddr$stall"}}
 f03 {Run-Sim savestate_eeprom replay.do f03_direct;$env:EEPROM_CASE='-1';foreach($stall in 0,1,2){$env:EEPROM_STALL="$stall";Run-Sim savestate_eeprom integration.do "f03_ddr$stall"};Run-Sim savestate_eeprom persistence.do f03_persistence}
 f05 {foreach($stall in 0,1,2){$env:SC_STALL="$stall";Run-Sim savestate_sc_ram integration.do "f05_ddr$stall"};$env:SC_STALL='0';Run-Sim savestate_sc_ram f10_controls.do f05_controls;Run-Sim savestate_sc_ram f10_persistence.do f05_persistence}
 psg {Run-Sim savestate_coverage psg.do psg}
}
