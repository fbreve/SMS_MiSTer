$ErrorActionPreference='Stop'
$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem'
Push-Location $PSScriptRoot
try {
 & "$bin/vsim.exe" -c -do 'do random_compile.do' -l random_compile.log *> random_compile_stdout.log
 if($LASTEXITCODE -or (Get-Content random_compile.log -Raw) -match '\*\* (Error|Fatal|Failure):|Errors: [1-9]'){throw 'F01 compile failed'}
 foreach($seed in @(1,10)){
  Push-Location "random_$seed"
  try{
   if(-not(Test-Path modelsim.ini)){& "$bin/vmap.exe" -c *> vmap.log}
   & "$bin/vmap.exe" work_random ../work_random *>> vmap.log
   & "$bin/vmap.exe" original_work ../original_work *>> vmap.log
   $env:RANDOMSEED="$seed";$env:REF='0';$env:STALL='1'
   & "$bin/vsim.exe" -c -do 'do ../random_run.do' -l replay.log *> replay_stdout.log
   $s=Get-Content replay.log -Raw
   if($LASTEXITCODE -or $s -notmatch 'PASS F01' -or $s -match '\*\* (Error|Fatal|Failure):|Errors: [1-9]'){throw "F01 seed $seed failed"}
   Write-Output "PASS F01 seed $seed"
  }finally{Pop-Location}
 }
}finally{Pop-Location}
