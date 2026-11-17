param([int]$Shard=0)
$ErrorActionPreference='Stop';$taskBin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem'
Push-Location "$PSScriptRoot/malformed_parallel/s$Shard"
try{
 if(-not(Test-Path modelsim.ini)){& "$taskBin/vmap.exe" -c *> vmap.log}
 & "$taskBin/vmap.exe" test_work ../test_work *>> vmap.log
 & "$taskBin/vsim.exe" -c -do 'do run.do' -l simulation.log *> stdout.log
 $taskLog=Get-Content simulation.log -Raw
 if($LASTEXITCODE -or $taskLog -notmatch "PASS ALIAS MALFORMED SHARD$Shard rejected" -or $taskLog -notmatch 'ALIAS MITER cycles' -or $taskLog -notmatch 'Errors: 0' -or $taskLog -match '\*\* (Error|Fatal|Failure)|Errors: [1-9]|Failed to open'){Get-Content simulation.log -Tail 12;throw "Malformed shard$Shard failed"}
 Write-Output "PASS malformed shard$Shard"
}finally{Pop-Location}
