$ErrorActionPreference='Stop';$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem'
Push-Location $PSScriptRoot
try {
 & "$bin/vsim.exe" -c -do 'do causal_compile.do' -l causal_compile.log *> causal_compile_stdout.log
 if((Get-Content causal_compile.log -Raw) -match '\*\* (Error|Fatal|Failure):|Errors: [1-9]'){throw 'Causal compile failed'}
 Push-Location causal
 try {
  if(-not(Test-Path modelsim.ini)){& "$bin/vmap.exe" -c *> vmap.log}; & "$bin/vmap.exe" fm_causal_work ../fm_causal_work *>> vmap.log;& "$bin/vmap.exe" original_work ../original_work *>> vmap.log
  & "$bin/vsim.exe" -c -do 'do ../causal_run.do' -l replay.log *> replay_stdout.log
  $s=Get-Content replay.log -Raw;if($s -notmatch 'PASS G08FM' -or $s -notmatch 'Errors: 0' -or $s -match '\*\* (Error|Fatal|Failure):'){throw 'Causal replay failed'}
  Write-Output 'PASS CAUSAL CACHE ONLY'
 }finally{Pop-Location}
}finally{Pop-Location}
