$ErrorActionPreference='Stop'
$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe'
Push-Location "$PSScriptRoot/native"
try{
 $env:FMCASE='0';$env:HISTORY='0';$env:REF='1';$env:STALL='0'
 & $bin -c -do 'do ../native_run.do' -l reference.log *> reference_stdout.log
 if($LASTEXITCODE -or !(Select-String -Quiet -Pattern 'PASS REFERENCE' reference.log)){throw 'Native reference failed'}
 $env:REF='0'
 & $bin -c -do 'do ../native_run.do' -l replay.log *> replay_stdout.log
 if($LASTEXITCODE -or !(Select-String -Quiet -Pattern 'PASS CHARACTERIZED' replay.log)){throw 'Native replay failed'}
}finally{Pop-Location}
