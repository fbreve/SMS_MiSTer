$ErrorActionPreference='Stop';$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem'
Push-Location $PSScriptRoot
try {
 Push-Location causal16
 try {
  if(-not(Test-Path modelsim.ini)){& "$bin/vmap.exe" -c *> vmap.log}; & "$bin/vmap.exe" fm_causal_work ../fm_causal_work *>> vmap.log;& "$bin/vmap.exe" original_work ../original_work *>> vmap.log
  & "$bin/vsim.exe" -c -do 'do ../causal16_run.do' -l replay.log *> replay_stdout.log
  $s=Get-Content replay.log -Raw;if($s -notmatch 'PASS G08FM' -or $s -notmatch 'Errors: 0' -or $s -match '\*\* (Error|Fatal|Failure):'){throw 'Causal replay failed'}
  Write-Output 'PASS CAUSAL CACHE ONLY'
 }finally{Pop-Location}
}finally{Pop-Location}
