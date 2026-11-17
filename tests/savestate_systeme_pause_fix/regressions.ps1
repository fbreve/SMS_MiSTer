param([string]$Group)
$ErrorActionPreference='Stop'
$root=(Resolve-Path "$PSScriptRoot/../..").Path
function Run-Sim([string]$Folder,[string]$Do,[string]$Label){
 Push-Location "$root/tests/$Folder"
 try{
  $out="$PSScriptRoot/reg_$Label.log"
  & 'C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe' -c -do $Do *> $out
  $code=$LASTEXITCODE;$s=Get-Content -Raw $out
  if($code -ne 0 -or $s -match '\*\* (Error|Fatal|Failure)|Errors: [1-9]' -or $s -notmatch 'PASS'){Get-Content $out -Tail 20;throw "Failed $Label"}
  Write-Output "PASS $Label"
 }finally{Pop-Location}
}
switch($Group){
 a {
  Run-Sim savestate_hcounter f11_controller.do f07_controller
  Run-Sim savestate_hcounter f11_integration.do f07_systeme
  $env:GG_FIXED='true';Run-Sim savestate_gg_io gg.do f02_direct
  foreach($i in 0,1){Run-Sim savestate_gg_io "f11_final$i.do" "f02_ddr$i"}
  Run-Sim savestate_md6 f10_real.do f08_real
  Run-Sim savestate_md6 f11_final.do f08_ddr
 }
 b {
  $env:TAP_TIMEOUT='8';Run-Sim savestate_master_tap replay.do f09_short
  $env:TAP_TIMEOUT='57000';Run-Sim savestate_master_tap replay.do f09_real
  Run-Sim savestate_master_tap ordinary.do f09_ordinary
  $env:TAP_STALL='0';$env:TAP_CASE='-1';Run-Sim savestate_master_tap f11_final0.do f09_ddr
  Run-Sim savestate_paddle directed.do f10_directed
  Run-Sim savestate_paddle replay.do f10_phases
  Run-Sim savestate_paddle modes.do f10_modes
  Run-Sim savestate_paddle ordinary.do f10_ordinary
  $env:PADDLE_CASE='-1';Run-Sim savestate_paddle stalls0.do f10_ddr
  foreach($i in 22,23,24,25){$env:PADDLE_CASE="$i";Run-Sim savestate_paddle stalls0.do "f10_case$i"}
 }
 c {
  Run-Sim savestate_eeprom replay.do f03_direct
  $env:EEPROM_STALL='0';$env:EEPROM_CASE='-1';Run-Sim savestate_eeprom f11_final0.do f03_ddr
  Run-Sim savestate_eeprom persistence.do f03_persistence
  $env:SC_STALL='0';Run-Sim savestate_sc_ram f11_final0.do f05_ddr
  Run-Sim savestate_sc_ram f10_controls.do f05_controls
  Run-Sim savestate_sc_ram f10_persistence.do f05_persistence
 }
 d {
  Run-Sim savestate_lightgun_fix direct.do f11_direct
  foreach($i in 0,3){Run-Sim savestate_lightgun_fix "cpu_stalls$i.do" "f11_cpu$i"}
  foreach($i in 0,1){Run-Sim savestate_lightgun_fix "io_order$i.do" "f11_order$i"}
  foreach($i in 0,1,2,3){Run-Sim savestate_lightgun_fix "format$i.do" "format$i"}
  Run-Sim savestate_coverage psg.do psg
 }
}
