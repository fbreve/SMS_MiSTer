param([ValidateSet('nmi','pause')][string]$Family='nmi')
$ErrorActionPreference='Stop';$taskBin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem'
if($Family -eq 'nmi'){$taskNames=@((Get-Content "$PSScriptRoot/nmi_cases.json" -Raw|ConvertFrom-Json)|ForEach-Object{$_.name});$taskLib='final_work';$taskMarker='PASS F16 fixed'}
else{$taskNames=@('s0_c0','s0_c1','s1_c0','s1_c1');$taskLib='pause_work';$taskMarker='PASS G12 LOAD_RUNNING'}
foreach($taskName in $taskNames){Push-Location "$PSScriptRoot/native_$Family/$taskName";try{
 if(-not(Test-Path modelsim.ini)){& "$taskBin/vmap.exe" -c *> vmap.log}
 & "$taskBin/vmap.exe" $taskLib "../$taskLib" *>> vmap.log
 & "$taskBin/vsim.exe" -c -do 'do run.do' -l simulation.log *> stdout.log
 $taskLog=Get-Content simulation.log -Raw
 if($LASTEXITCODE -or $taskLog -notmatch $taskMarker -or $taskLog -notmatch 'ALIAS MITER cycles' -or $taskLog -notmatch 'Errors: 0' -or $taskLog -match '\*\* (Error|Fatal|Failure)|Errors: [1-9]|Failed to open'){Get-Content simulation.log -Tail 18;throw "STOP $Family/$taskName"}
 Write-Output "PASS $Family/$taskName"
}finally{Pop-Location}}
