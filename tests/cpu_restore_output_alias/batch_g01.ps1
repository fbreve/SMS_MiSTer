$ErrorActionPreference='Stop'
$taskBin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem'
$taskCases=Get-Content "$PSScriptRoot/g01_cases.json" -Raw|ConvertFrom-Json
foreach($taskCase in $taskCases){
 $taskName='p'+$taskCase.args.PROGRAM
 Push-Location "$PSScriptRoot/native_g01/$taskName"
 try{
 if(-not(Test-Path modelsim.ini)){& "$taskBin/vmap.exe" -c *> vmap.log}
 & "$taskBin/vmap.exe" trace_work ../trace_work *>> vmap.log
 & "$taskBin/vsim.exe" -c -do 'do run.do' -l simulation.log *> stdout.log
 $taskLog=Get-Content simulation.log -Raw
 if($LASTEXITCODE -or $taskLog -notmatch 'PASS G01 TRACE' -or $taskLog -notmatch 'ALIAS MITER cycles' -or $taskLog -notmatch 'Errors: 0' -or $taskLog -match '\*\* (Error|Fatal|Failure)|Errors: [1-9]|Failed to open'){Get-Content simulation.log -Tail 15;throw "STOP G01 $taskName"}
 Write-Output "PASS G01 $taskName"
 }finally{Pop-Location}
}
