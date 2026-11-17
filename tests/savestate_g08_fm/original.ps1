$ErrorActionPreference='Stop';$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem'
Push-Location "$PSScriptRoot/release_original"
try {
 if(-not(Test-Path modelsim.ini)){& "$bin/vmap.exe" -c *> vmap.log}
 & "$bin/vsim.exe" -c -do 'do compile.do' -l compile.log *> compile_stdout.log
 if((Get-Content compile.log -Raw) -match '\*\* (Error|Fatal|Failure):|Errors: [1-9]'){throw 'Original compile failed'}
 $env:REF='0';$env:SEED='0';$env:TARGET='0'
 foreach($stall in 0,1){
  $env:STALL="$stall"
  & "$bin/vsim.exe" -c -do 'do run.do' -l "stall$stall.log" *> "stall$($stall)_stdout.log"
  $s=Get-Content "stall$stall.log" -Raw
  if($s -notmatch 'PASS CHARACTERIZED' -or $s -notmatch 'Errors: 0' -or $s -match '\*\* (Error|Fatal|Failure):|Errors: [1-9]'){throw "Original stall$stall failed"}
  Copy-Item image.hex "image_stall$stall.hex";Write-Output "PASS ORIGINAL stall$stall"
 }
}finally{Pop-Location}
