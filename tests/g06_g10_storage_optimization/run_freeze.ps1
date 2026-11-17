$ErrorActionPreference='Stop'
Push-Location $PSScriptRoot
try {
 & 'C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe' -c -do 'do freeze.do' -l freeze.log *> freeze_stdout.log
 $taskExit=$LASTEXITCODE
 $taskLog=Get-Content freeze.log -Raw
 if($taskExit -or $taskLog -notmatch 'PASS FREEZE ALL' -or $taskLog -notmatch 'Errors: 0' -or $taskLog -match '\*\* (Error|Fatal|Failure)|Errors: [1-9]'){throw 'Baseline freeze probe failed'}
 Write-Output 'Baseline freeze probe passed'
} finally {Pop-Location}
