$ErrorActionPreference='Stop';$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem'
Push-Location $PSScriptRoot
try {
 & "$bin/vsim.exe" -c -do 'do candidate_compile.do' -l candidate_compile.log *> candidate_compile_stdout.log
 if((Get-Content candidate_compile.log -Raw) -match '\*\* (Error|Fatal|Failure):|Errors: [1-9]'){throw 'Causal compile failed'}
 Push-Location candidate_case70
 try {
  if(-not(Test-Path modelsim.ini)){& "$bin/vmap.exe" -c *> vmap.log}; & "$bin/vmap.exe" fm_candidate_work ../fm_candidate_work *>> vmap.log;& "$bin/vmap.exe" original_work ../original_work *>> vmap.log
  & "$bin/vsim.exe" -c -do 'do ../candidate_run.do' -l replay.log *> replay_stdout.log
  $s=Get-Content replay.log -Raw;if($s -notmatch 'PASS G08FM' -or $s -notmatch 'Errors: 0' -or $s -match '\*\* (Error|Fatal|Failure):'){throw 'Causal replay failed'}
  Write-Output 'PASS ISOLATED CANDIDATE'
 }finally{Pop-Location}
}finally{Pop-Location}
