$ErrorActionPreference='Stop'
Push-Location (Join-Path $PSScriptRoot 'original_combined')
try {
$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem'
& "$bin/vmap.exe" -c | Out-Null
& "$bin/vsim.exe" -c -do 'do compile.do' -l compile.log *> compile_stdout.log
if($LASTEXITCODE -or (Get-Content -Raw compile.log) -match '\*\* (Error|Fatal|Failure)'){throw 'Compile failed'}
$env:REF='1';$env:SEED='0';$env:TARGET='0';$env:STALL='0'
& "$bin/vsim.exe" -c -do 'do run.do' -l reference.log *> reference_stdout.log
if($LASTEXITCODE){throw 'Reference failed'}
$env:REF='0'
& "$bin/vsim.exe" -c -do 'do run.do' -l unstalled.log *> unstalled_stdout.log
if($LASTEXITCODE){throw 'Replay failed'}
Copy-Item image.hex image_unstalled.hex
$env:STALL='1'
& "$bin/vsim.exe" -c -do 'do run.do' -l stalled.log *> stalled_stdout.log
if($LASTEXITCODE){throw 'Stalled replay failed'}
}finally{Pop-Location}
