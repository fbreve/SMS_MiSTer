param([string]$Group)
$ErrorActionPreference='Stop'
$root=Resolve-Path "$PSScriptRoot/../.."
$sim='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe'
function Run-Sim([string]$Folder,[string]$Do,[string]$Label){
 Push-Location "$root/tests/$Folder"
 try{
  $out="$PSScriptRoot/$Label.log"
  & $sim -c -do $Do *> $out
  $code=$LASTEXITCODE;$s=Get-Content -Raw $out
  if($code -ne 0 -or $s -match '\*\* (Error|Fatal|Failure)|Errors: [1-9]' -or $s -notmatch 'PASS'){Get-Content $out -Tail 20;throw "Failed $Label"}
  Write-Output "PASS $Label"
 }finally{Pop-Location}
}
switch($Group){
 f07 {Run-Sim savestate_hcounter f11_controller.do final_f07_controller;Run-Sim savestate_hcounter f11_integration.do final_f07_integration}
 f02 {foreach($i in 0,1){Run-Sim savestate_gg_io "f11_final$i.do" "final_f02_ddr$i"}}
 f08 {Run-Sim savestate_md6 f11_final.do final_f08_ddr}
 f10 {foreach($i in 0,1,2){$env:PADDLE_CASE='-1';Run-Sim savestate_paddle "stalls$i.do" "final_f10_ddr$i";foreach($case in 0,1,2,20,21,22,23,24,25){$env:PADDLE_CASE="$case";Run-Sim savestate_paddle "stalls$i.do" "final_f10_case${case}_stall$i"}}}
 controls {Run-Sim savestate_eeprom persistence.do final_f03_persistence;$env:SC_STALL='0';Run-Sim savestate_sc_ram f10_controls.do final_f05_controls;Run-Sim savestate_sc_ram f10_persistence.do final_f05_persistence}
 default {
  if($Group -match '^(f03|f05|f09|f10)_(\d)$'){
   $kind=$Matches[1];$i=[int]$Matches[2];$env:EEPROM_STALL="$i";$env:EEPROM_CASE='-1';$env:SC_STALL="$i";$env:TAP_STALL="$i";$env:TAP_CASE='-1'
   switch($kind){
    f03 {Run-Sim savestate_eeprom "f11_final$i.do" "final_f03_ddr$i"}
    f05 {Run-Sim savestate_sc_ram "f11_final$i.do" "final_f05_ddr$i"}
    f09 {Run-Sim savestate_master_tap "f11_final$i.do" "final_f09_ddr$i"}
    f10 {$env:PADDLE_CASE='-1';Run-Sim savestate_paddle "stalls$i.do" "final_f10_ddr$i";foreach($case in 0,1,2,20,21,22,23,24,25){$env:PADDLE_CASE="$case";Run-Sim savestate_paddle "stalls$i.do" "final_f10_case${case}_stall$i"}}
   }
   break
  }
  $i=[int]$Group;$env:EEPROM_STALL="$i";$env:EEPROM_CASE='-1';$env:SC_STALL="$i";$env:TAP_STALL="$i";$env:TAP_CASE='-1'
  Run-Sim savestate_eeprom "f11_final$i.do" "final_f03_ddr$i"
  Run-Sim savestate_sc_ram "f11_final$i.do" "final_f05_ddr$i"
  Run-Sim savestate_master_tap "f11_final$i.do" "final_f09_ddr$i"
 }
}
