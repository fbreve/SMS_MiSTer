param([string]$Group='short')
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
 f07 {Run-Sim savestate_hcounter f11_controller.do f07_controller;Run-Sim savestate_hcounter f11_integration.do f07_systeme_dual_vdp}
 short {
  Run-Sim savestate_md6 f10_real.do f08_md6
  $env:TAP_TIMEOUT='8';Run-Sim savestate_master_tap replay.do f09_tap
  Run-Sim savestate_paddle directed.do f10_paddle_directed
  Run-Sim savestate_paddle replay.do f10_paddle_replay
  Run-Sim savestate_paddle modes.do f10_paddle_modes
  Run-Sim savestate_lightgun_fix direct.do f11_lightgun_direct
  Run-Sim savestate_lightgun_fix cpu_stalls0.do f11_lightgun_cpu
  Run-Sim savestate_coverage psg.do psg
 }
 f11 {Run-Sim savestate_lightgun_fix io_order0.do f11_lightgun_restore_order}
}
