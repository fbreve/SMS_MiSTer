param([string]$Group='core')
$ErrorActionPreference='Stop'
& 'C:/Program Files/nodejs/node.exe' "$PSScriptRoot/refresh_model.js"
if($LASTEXITCODE -ne 0){throw 'Production controller refresh failed'}
$env:F14_STALL='0'
function Sim([string]$Do,[string]$Label){
 Push-Location $PSScriptRoot
 try{
  & 'C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe' -c -do $Do *> "$Label.log"
  $code=$LASTEXITCODE;$s=Get-Content -Raw "$Label.log"
  if($code -ne 0 -or $s -match '\*\* (Error|Fatal|Failure)|Errors: [1-9]' -or $s -notmatch 'PASS'){Get-Content "$Label.log" -Tail 18;throw "Failed $Label"}
  Write-Output "PASS $Label"
 }finally{Pop-Location}
}
switch($Group){
 core {foreach($i in 0..14){$env:F14_CASE="$i";Sim run.do "fixed_case$i"}}
 stress {$env:F14_STALL='1';foreach($i in 0,2,3,4,12){$env:F14_CASE="$i";Sim run.do "stress_case$i"}}
 bits {foreach($i in 15..30){$env:F14_CASE="$i";Sim run.do "bits_case$i"}}
 pre {foreach($i in 0..3){$env:F14_CASE="$i";Sim pre.do "pre_case$i"}}
 cpu {Sim cpu.do cpu;Sim history.do history}
 history {Sim history.do history}
 f13 {$env:F13_CASE='0';Sim f13_run.do f13_dahjee;$env:F13_CASE='6';Sim f13_run.do f13_deadline;Sim banking.do reg_banking}
 format {Sim format.do format}
 compat {Sim compat.do compat}
}
