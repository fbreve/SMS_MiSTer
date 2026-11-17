param([string]$Family='g03',[string]$Name='dut_bus',[switch]$Compile)
$ErrorActionPreference='Stop'
$taskBin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem'
$taskDir=Join-Path $PSScriptRoot "native_$Family"
if($Compile){
 Push-Location $taskDir
 try{& "$taskBin/vsim.exe" -c -do 'do compile.do' -l compile.log *> compile_stdout.log
 if($LASTEXITCODE -or (Get-Content compile.log -Raw) -match '\*\* (Error|Fatal|Failure)'){throw 'Compile failed'}
 Write-Output "PASS compile $Family"}finally{Pop-Location}
}else{
 Push-Location "$taskDir/$Name"
 try{
 if(-not(Test-Path modelsim.ini)){& "$taskBin/vmap.exe" -c *> vmap.log}
 & "$taskBin/vmap.exe" vdp_work ../vdp_work *>> vmap.log
 & "$taskBin/vsim.exe" -c -do 'do run.do' -l simulation.log *> stdout.log
 $taskLog=Get-Content simulation.log -Raw
 if($LASTEXITCODE -or $taskLog -notmatch 'PASS V15 VDP' -or $taskLog -notmatch 'ALIAS MITER cycles' -or $taskLog -notmatch 'Errors: 0' -or $taskLog -match '\*\* (Error|Fatal|Failure)|Errors: [1-9]|Failed to open'){Get-Content simulation.log -Tail 16;throw 'Functional mismatch or missing PASS'}
 Write-Output "PASS $Family/$Name"
 }finally{Pop-Location}
}
