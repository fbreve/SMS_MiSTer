param([string]$Family='sprites',[string]$Case='dut_collision',[switch]$Compile)
$ErrorActionPreference='Stop'
$sim='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe'
$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem'
$base=Join-Path $PSScriptRoot $Family
if($Compile){
 Push-Location $base
 try{& $sim -c -do 'do compile.do' -l compile.log *> compile_stdout.log
  $s=Get-Content compile.log -Raw
  if($LASTEXITCODE -or $s -match '\*\* (Error|Fatal|Failure):|Errors: [1-9]'){throw 'Compile failed'}
 }finally{Pop-Location}
}
Push-Location "$base/$Case"
try{
 & "$bin/vmap.exe" -c *> vmap.log
 & "$bin/vmap.exe" vdp_work ../vdp_work *>> vmap.log
 & $sim -c -do 'do run.do' -l simulation.log *> simulation_stdout.log
 $s=Get-Content simulation.log -Raw
 if($LASTEXITCODE -or $s -notmatch 'PASS |DONE VDP' -or $s -notmatch 'Errors: 0' -or $s -match '\*\* (Error|Fatal|Failure):|Errors: [1-9]|Failed to open readmem|Failed to open file'){Get-Content simulation.log -Tail 16;throw "FAIL $Family/$Case"}
 Write-Output "PASS $Family/$Case"
}finally{Pop-Location}
