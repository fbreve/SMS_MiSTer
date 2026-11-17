param([string]$Group)
$ErrorActionPreference='Stop'
function Sim([string]$Folder,[string]$Do,[string]$Label){
 Push-Location "$PSScriptRoot/regressions/$Folder"
 try{
  & 'C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe' -c -do $Do *> "$PSScriptRoot/reg_$Label.log"
  $code=$LASTEXITCODE;$s=Get-Content -Raw "$PSScriptRoot/reg_$Label.log"
  if($code -ne 0 -or $s -match '\*\* (Error|Fatal|Failure)|Errors: [1-9]' -or $s -notmatch 'PASS'){Get-Content "$PSScriptRoot/reg_$Label.log" -Tail 16;throw "Failed $Label"}
  Write-Output "PASS $Label"
 }finally{Pop-Location}
}
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
  $env:PAUSE_CASE='4';$env:PAUSE_KEEP='0';$env:PAUSE_FULL='0';$env:PAUSE_STALL='0';$env:PAUSE_OFFSET='0';$env:PAUSE_DELAY='6'
  Sim savestate_systeme_pause_fix fixed_case4_stall0_full0_offset0_delay6.do f12_paused
  Sim savestate_coverage psg.do psg
 }
}
