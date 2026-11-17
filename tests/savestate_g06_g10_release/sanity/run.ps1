$ErrorActionPreference='Stop'
$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe'
function Invoke-Sanity($folder,$script,$log,$marker) {
 Push-Location (Join-Path $PSScriptRoot $folder)
 try {
  & $bin -c -do "do $script" -l $log
  $text=Get-Content -Raw $log
  if($LASTEXITCODE -ne 0 -or $text -match '\*\* (Error|Fatal|Failure)|Errors: [1-9]' -or $text -notmatch $marker){throw "Sanity failed: $log"}
 } finally { Pop-Location }
}
Invoke-Sanity '.' 'g01.do' 'g01.log' 'PASS G01 TRACE'
Invoke-Sanity '.' 'hcounter.do' 'hcounter.log' 'PASS: F07 fixed'
$env:FIX_SOURCE=0;$env:FIX_PROGRAM=0;$env:FIX_EDGE=0;$env:FIX_WIDTH=1
$env:FIX_SECOND=9999999;$env:FIX_HELD=0;$env:FIX_SCHEDULE=0;$env:FIX_FORMAT=0
Invoke-Sanity 'nmi' 'run.do' 'simulation.log' 'PASS F16 fixed'
$env:PAUSE_CASE=4;$env:PAUSE_KEEP=0;$env:PAUSE_FULL=0
$env:PAUSE_STALL=0;$env:PAUSE_OFFSET=0;$env:PAUSE_DELAY=6
Invoke-Sanity 'pause' 'run.do' 'simulation.log' 'PASS FIXED case4'
