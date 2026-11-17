param([string]$Group='a')
$ErrorActionPreference='Stop'
$sim="$PSScriptRoot/sim.ps1"
function Sim([string]$Folder,[string]$Do,[string]$Label){& $sim -Folder "$PSScriptRoot/regressions/$Folder" -Do $Do -Label $Label}
switch($Group){
 a {
  Sim sram_architecture run.do mapper_memory
  Sim savestate_eeprom replay.do eeprom_direct
  $env:EEPROM_CASE='-1';$env:EEPROM_STALL='0';Sim savestate_eeprom f11_final0.do eeprom_ddr
  Sim savestate_eeprom persistence.do eeprom_persistence
  $env:SC_STALL='0';Sim savestate_sc_ram f11_final0.do sc_ram
 }
 b {
  Sim savestate_hcounter f11_controller.do f07_controller
  Sim savestate_hcounter f11_integration.do f07_systeme
  $env:GG_FIXED='true';Sim savestate_gg_io gg.do f02_direct
  Sim savestate_gg_io f11_final0.do f02_ddr
  Sim savestate_md6 f10_real.do f08_md6
  $env:TAP_TIMEOUT='8';Sim savestate_master_tap replay.do f09_tap
  Sim savestate_paddle directed.do f10_paddle
  Sim savestate_lightgun_fix direct.do f11_lightgun
  foreach($i in 0,3){Sim savestate_lightgun_fix "format$i.do" "f11_format$i"}
  Sim savestate_coverage psg.do psg
 }
 format {
  $env:F14_STALL='0'
  & $sim -Folder "$PSScriptRoot/regression" -Do format.do -Label evolution_formats
  & $sim -Folder "$PSScriptRoot/regression" -Do compat.do -Label prior_formats
 }
}
