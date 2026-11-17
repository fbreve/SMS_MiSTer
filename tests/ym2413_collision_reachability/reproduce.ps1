$ErrorActionPreference='Stop'
Set-Location $PSScriptRoot
node prepare.js
if($LASTEXITCODE){throw 'Preparation failed'}
node make_tb.js
& "$PSScriptRoot/run.ps1" -ToolInfo
& "$PSScriptRoot/run.ps1" -CompileOnly
& "$PSScriptRoot/run.ps1"
foreach($taskCase in @(11,12,13,14)){& "$PSScriptRoot/run.ps1" -Case $taskCase}
foreach($taskCase in @(3,11)){& "$PSScriptRoot/run.ps1" -Case $taskCase -Mode 6}
& "$PSScriptRoot/run.ps1" -Case 15 -Mode 0
& "$PSScriptRoot/run.ps1" -Coherent
& "$PSScriptRoot/boundaries.ps1"
foreach($taskCase in @(0,1)){& "$PSScriptRoot/run.ps1" -Case $taskCase -Mode 2 -Gap 13}
& "$PSScriptRoot/run.ps1" -Case 3 -Mode 3 -Follow 65536
node make_validator.js
& 'C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe' -c -do validate.do -l validator.log
if(!(Select-String -Path validator.log -Pattern 'PASS validator checked=')){throw 'Validator did not pass'}
node make_clock_check.js
& 'C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe' -c -do clock_check.do -l clock_check.log
if(!(Select-String -Path clock_check.log -Pattern 'PASS production divider ARM checks=')){throw 'Clock check did not pass'}
node collect.js
if($LASTEXITCODE){throw 'Collection failed'}
