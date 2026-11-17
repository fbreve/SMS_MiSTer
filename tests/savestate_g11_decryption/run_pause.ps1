param([int]$Mode=2,[int]$SavedPaused=0,[int]$CurrentPaused=0,[int]$Delay=0,[int]$N=12000,[switch]$Compile)
$ErrorActionPreference='Stop';$main=Join-Path $PSScriptRoot pause;$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem'
if($Compile){Push-Location $main;try{
 & "$bin/vmap.exe" -c | Out-Null
 & "$bin/vsim.exe" -c -do 'do compile.do' -l compile.log *> compile_stdout.log
 if($LASTEXITCODE -or (Get-Content -Raw compile.log) -match '\*\* (Error|Fatal|Failure)'){throw 'compile failed'}
 & "$bin/vmap.exe" pause_work "$main/pause_work" | Out-Null
}finally{Pop-Location}}
$leaf=Join-Path $main "m$Mode`_s$SavedPaused`_c$CurrentPaused`_d$Delay";New-Item -ItemType Directory -Force $leaf | Out-Null
Get-ChildItem -LiteralPath $main -Filter '*.hex'|Copy-Item -Destination $leaf
[IO.File]::WriteAllLines((Join-Path $leaf run.do),@('onerror {quit -code 1}','onbreak {quit -code 1}',"vsim -c -t 1ps -L altera_mf pause_work.pause_tb -g/pause_tb/MODE=$Mode -g/pause_tb/PROGRAM=1 -g/pause_tb/DUAL=0 -g/pause_tb/BOOT=1200 -g/pause_tb/N=$N -g/pause_tb/TAIL_DELAY=$Delay -g/pause_tb/SAVED_PAUSED=$SavedPaused -g/pause_tb/CURRENT_PAUSED=$CurrentPaused -g/pause_tb/dut/TB_FAST=1",'set NumericStdNoWarnings 1','set StdArithNoWarnings 1','run -all','quit -code 0'))
Push-Location $leaf;try{
 & "$bin/vsim.exe" -c -modelsimini "$main/modelsim.ini" -do 'do run.do' -l simulation.log *> simulation_stdout.log
 $s=Get-Content -Raw simulation.log
 if($LASTEXITCODE -or $s -match '\*\* (Error|Fatal|Failure)' -or $s -notmatch 'PASS G11 PAUSE' -or $s -match 'CONFIRMED G12'){throw 'Retain and classify Pause failure before continuing'}
 Write-Output "PASS G11 PAUSE mode$Mode saved$SavedPaused current$CurrentPaused delay$Delay"
}finally{Pop-Location}
