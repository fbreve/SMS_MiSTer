param([ValidateSet('baseline','prototype','protocol','final_protocol')][string]$Fixture='baseline',[int]$Delay=8,[int]$Fast=1,[int]$SavedPaused=1,[int]$CurrentPaused=0,[int]$Tac=1,[switch]$Compile)
$ErrorActionPreference='Stop'
$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem'
$main=Join-Path $PSScriptRoot $Fixture
Push-Location $main
try {
 if($Compile){
  & "$bin/vmap.exe" -c | Out-Null
  & "$bin/vsim.exe" -c -do 'do compile.do' -l compile.log *> compile_stdout.log
  if($LASTEXITCODE -or (Get-Content -Raw compile.log) -match '\*\* (Error|Fatal|Failure)'){throw 'compile failed'}
  & "$bin/vmap.exe" pause_work "$main/pause_work" | Out-Null
 }
 $leaf=Join-Path $main "s$SavedPaused`_c$CurrentPaused`_d$Delay`_f$Fast"
 if($Tac -ne 1){$leaf+="_t$Tac"}
 New-Item -ItemType Directory -Force $leaf | Out-Null
 Copy-Item rom.hex (Join-Path $leaf rom.hex)
 $lines=@('onerror {quit -code 1}','onbreak {quit -code 1}',"vsim -c -t 1ps -L altera_mf pause_work.pause_tb -gDUAL=0 -gBOOT=1200 -gTAIL_DELAY=$Delay -gSAVED_PAUSED=$SavedPaused -gCURRENT_PAUSED=$CurrentPaused -gTAC=$Tac -g/pause_tb/dut/TB_FAST=$Fast",'set NumericStdNoWarnings 1','set StdArithNoWarnings 1','run -all','quit -code 0')
 [IO.File]::WriteAllLines((Join-Path $leaf run.do),$lines)
 Push-Location $leaf
 try {
  & "$bin/vsim.exe" -c -modelsimini "$main/modelsim.ini" -do 'do run.do' -l simulation.log *> simulation_stdout.log
  $s=Get-Content -Raw simulation.log
  if($LASTEXITCODE -or $s -match '\*\* (Error|Fatal|Failure)' -or $s -notmatch '(CONFIRMED G12|PASS G12 LOAD_RUNNING)'){throw 'characterization incomplete'}
  if($Fixture -ne 'baseline' -and $s -match 'CONFIRMED G12'){throw 'prototype counterexample'}
  if($Fixture -match 'protocol' -and $s -notmatch 'PASS_REISSUE'){throw 'missing exactly-once proof'}
  $s -split "`r?`n" | Where-Object {$_ -match 'CONFIRMED G12|PASS G12 LOAD_RUNNING|LOAD_RUNNING_RELEASE|PAUSED_IMAGE'}
 }finally{Pop-Location}
}finally{Pop-Location}
