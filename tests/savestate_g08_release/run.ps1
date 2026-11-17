param([switch]$Prepare)
$ErrorActionPreference='Stop'
Push-Location $PSScriptRoot
try {
 if($Prepare){& 'C:/Program Files/nodejs/node.exe' prepare.js;if($LASTEXITCODE){throw 'Preparation failed'}}
 $bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem'
 & "$bin/vmap.exe" -c | Out-Null
 & "$bin/vsim.exe" -c -do 'do compile.do' -l compile.log *> compile_stdout.log
 if($LASTEXITCODE -or (Get-Content -Raw compile.log) -match '\*\* (Error|Fatal|Failure)'){throw 'Compile failed'}
 $env:SEED='0';$env:TARGET='0';$env:STALL='0';$env:REF='1'
 & "$bin/vsim.exe" -c -do 'do run.do' -l final_reference.log *> final_reference_stdout.log
 if($LASTEXITCODE){throw 'Reference failed'}
 $env:REF='0'
 & "$bin/vsim.exe" -c -do 'do run.do' -l final_replay.log *> final_replay_stdout.log
 if($LASTEXITCODE){throw 'Replay failed'}
 Copy-Item -LiteralPath image.hex -Destination image_unstalled.hex
 $env:STALL='1'
 & "$bin/vsim.exe" -c -do 'do run.do' -l final_stalls.log *> final_stalls_stdout.log
 if($LASTEXITCODE){throw 'Stalled replay failed'}
 & 'C:/Program Files/nodejs/node.exe' audit.js
 if($LASTEXITCODE){throw 'Evidence audit failed'}
}finally{Pop-Location}
