param([string]$Group='f14')
$ErrorActionPreference='Stop'
function Sim([string]$Folder,[string]$Do,[string]$Label){
 Push-Location $Folder
 try {
  & 'C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe' -c -do $Do *> "$PSScriptRoot/$Label.log"
  $code=$LASTEXITCODE;$s=Get-Content -Raw "$PSScriptRoot/$Label.log"
  if($code -ne 0 -or $s -match '\*\* (Error|Fatal|Failure)|Errors: [1-9]' -or $s -notmatch 'PASS'){Get-Content "$PSScriptRoot/$Label.log" -Tail 20;throw "Failed $Label"}
  Write-Output "PASS $Label"
 } finally {Pop-Location}
}
switch($Group){
 f14 {foreach($i in 0..14){$env:F14_CASE="$i";Sim $PSScriptRoot run.do "case$i"}}
 cpu {Sim $PSScriptRoot cpu.do cpu}
 history {Sim $PSScriptRoot history.do history}
 regressions {
  Sim $PSScriptRoot banking.do banking
  $env:F13_CASE='0';Sim $PSScriptRoot f13_run.do f13_dahjee
  $env:F13_CASE='6';Sim $PSScriptRoot f13_run.do f13_deadline
  Sim "$PSScriptRoot/regressions/savestate_hcounter" f11_controller.do f07
  Sim "$PSScriptRoot/regressions/savestate_md6" f10_real.do f08
  $env:TAP_TIMEOUT='8';Sim "$PSScriptRoot/regressions/savestate_master_tap" replay.do f09
  Sim "$PSScriptRoot/regressions/savestate_paddle" directed.do f10
  Sim "$PSScriptRoot/regressions/savestate_lightgun_fix" direct.do f11
  $env:PAUSE_CASE='4';$env:PAUSE_KEEP='0';$env:PAUSE_FULL='0';$env:PAUSE_STALL='0';$env:PAUSE_OFFSET='0';$env:PAUSE_DELAY='6'
  Sim "$PSScriptRoot/regressions/savestate_systeme_pause_fix" fixed_case4_stall0_full0_offset0_delay6.do f12
 }
}
