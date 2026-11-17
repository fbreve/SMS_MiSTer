$ErrorActionPreference='Stop'
$root=(Resolve-Path "$PSScriptRoot/../..").Path
function Sim([string]$folder,[string]$do,[string]$label){
 Push-Location "$root/$folder"
 try{
  & 'C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe' -c -do $do *> "$PSScriptRoot/reg_$label.log"
  $code=$LASTEXITCODE;$s=Get-Content -Raw "$PSScriptRoot/reg_$label.log"
  if($code -ne 0 -or $s -match '\*\* (Error|Fatal|Failure)|Errors: [1-9]' -or $s -notmatch 'PASS'){Get-Content "$PSScriptRoot/reg_$label.log" -Tail 15;throw "Failed $label"}
  Write-Output "PASS $label"
 }finally{Pop-Location}
}
& 'C:/Program Files/nodejs/node.exe' "$root/tests/savestate_systeme_pause_fix/prepare_regressions.js"
Sim tests/savestate_mapper_detection banking.do banking
Sim tests/sram_architecture run.do mapper_memory
$env:EEPROM_STALL='0';$env:EEPROM_CASE='-1'
Sim tests/savestate_eeprom replay.do eeprom_direct
Sim tests/savestate_eeprom f11_final0.do eeprom_ddr
Sim tests/savestate_eeprom persistence.do eeprom_persistence
$env:SC_STALL='0'
Sim tests/savestate_sc_ram f11_final0.do sc_ram
Sim tests/savestate_hcounter f11_controller.do f07_controller
Sim tests/savestate_hcounter f11_integration.do f07_systeme
Sim tests/savestate_md6 f10_real.do f08_md6
$env:TAP_TIMEOUT='8';Sim tests/savestate_master_tap replay.do f09_tap
Sim tests/savestate_paddle directed.do f10_paddle
Sim tests/savestate_lightgun_fix direct.do f11_lightgun
& 'C:/Program Files/nodejs/node.exe' "$root/tests/savestate_systeme_pause_fix/prepare.js"
$env:PAUSE_CASE='4';$env:PAUSE_KEEP='0';$env:PAUSE_FULL='0';$env:PAUSE_STALL='0';$env:PAUSE_OFFSET='0';$env:PAUSE_DELAY='6'
Sim tests/savestate_systeme_pause_fix fixed_case4_stall0_full0_offset0_delay6.do f12_paused
