param([int]$Worker=0,[int]$Workers=2,[switch]$Compile)
$ErrorActionPreference='Stop';$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem'
Push-Location "$PSScriptRoot/f01"
try {
 if($Compile){& "$bin/vsim.exe" -c -do 'do compile.do' -l compile.log *> compile_stdout.log;if((Get-Content compile.log -Raw) -match '\*\* (Error|Fatal|Failure):|Errors: [1-9]'){throw 'F01 compile failed'}}
 for($seed=1+$Worker;$seed -le 16;$seed+=$Workers){
  Push-Location "random_$seed"
  try {
   if(-not(Test-Path modelsim.ini)){& "$bin/vmap.exe" -c *> vmap.log};& "$bin/vmap.exe" work_random ../work_random *>> vmap.log;& "$bin/vmap.exe" original_work ../original_work *>> vmap.log
   $env:RANDOMSEED="$seed";$env:REF='0';$env:STALL='1'
   & "$bin/vsim.exe" -c -do 'do ../random_run.do' -l replay.log *> replay_stdout.log
   $s=Get-Content replay.log -Raw;if($s -notmatch 'PASS F01' -or $s -notmatch 'Errors: 0' -or $s -match '\*\* (Error|Fatal|Failure):|Errors: [1-9]'){throw "F01 seed$seed failed"}
   Write-Output "PASS F01 seed$seed"
  }finally{Pop-Location}
 }
}finally{Pop-Location}
