param([string[]]$Names=@('pair_b','converge_a','converge_b','isolation','pending','decay','stalled','native','loop'),[int]$Group=0)
if($Group -eq 1){$Names=@('pair_b','converge_a','converge_b')}
if($Group -eq 2){$Names=@('isolation','pending','decay','stalled','native','loop')}
$ErrorActionPreference='Stop'
$sim='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe'
foreach($name in $Names){
 $case=0;$history=0;$stall=0;$seed=0;$converge=0;$suppress=0;$target=0;$rom='rom.hex';$library='work_v17';$top='pause_tb';$retained='';
 switch($name){
 'pair_b'{$history=1}
 'converge_a'{$converge=1}
 'converge_b'{$converge=1;$history=1}
 'isolation'{$suppress=1}
 'pending'{$suppress=1;$target=1}
 'decay'{$case=2;$seed=12000;$retained='decay'}
 'stalled'{$stall=1;$retained='case0'}
 'native'{$rom='native_rom.hex';$library='work_native_v17';$top='native_tb';$retained='native'}
 'loop'{$rom='loop_rom.hex';$library='work_loop_v17';$top='loop_tb'}
 default {throw "Unknown case $name"}
 }
 $caseDir=Join-Path $PSScriptRoot $name;New-Item -ItemType Directory -Force -Path $caseDir | Out-Null
 Copy-Item -LiteralPath "$PSScriptRoot/$rom" -Destination "$caseDir/$rom"
 $taskIni=(Get-Content "$PSScriptRoot/../savestate_f01_opll_architecture/modelsim.ini" -Raw).Replace('[Library]',("[Library]`n$library = "+$PSScriptRoot.Replace('\','/')+'/'+$library))
 Set-Content -LiteralPath "$caseDir/modelsim.ini" -Value $taskIni
 $do=@"
onerror {quit -code 1}
onbreak {quit -code 1}
vsim -t 1ps -voptargs=+acc $library.$top -gFMCASE=$case -gHISTORY=$history -gSTALL=$stall -gSEED=$seed -gCONVERGE=$converge -gFM_SUPPRESS=$suppress -gTARGET=$target -gREF=`$env(REF) -g/$top/dut/TB_FAST=1
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
"@
 Set-Content -LiteralPath "$caseDir/run.do" -Value $do
 Push-Location $caseDir
 try {
  if($retained){Copy-Item -LiteralPath "$PSScriptRoot/../savestate_f01_opll_architecture/$retained/reference.dat" -Destination reference.dat}
  else {
   $env:REF='1';& $sim -c -do 'do run.do' -l reference.log *> reference_stdout.log
   if($LASTEXITCODE -ne 0 -or !(Select-String -Quiet -Pattern 'PASS REFERENCE' reference.log)){throw "Reference failed $name"}
  }
  $env:REF='0';& $sim -c -do 'do run.do' -l replay.log *> replay_stdout.log
  if($LASTEXITCODE -ne 0 -or !(Select-String -Quiet -Pattern 'PASS F01' replay.log) -or (Select-String -Quiet -Pattern '\*\* (Fatal|Failure|Error):' replay.log)){throw "Replay failed $name"}
  if(@(Select-String -Pattern 'FM_RESULT pass[0-3] errors0 first-1' replay.log).Count -ne 4){throw "Incomplete case $name"}
 }finally{Pop-Location}
 Write-Output "PASS $name SAVE + three LOADs"
}
