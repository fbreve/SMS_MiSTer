param([Parameter(Mandatory=$true)][string]$Family,[Parameter(Mandatory=$true)][string]$Name)
$ErrorActionPreference='Stop'
$taskBin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem'
$taskRows=Get-Content "$PSScriptRoot/native_manifest.json" -Raw|ConvertFrom-Json
$taskCase=@($taskRows|Where-Object {$_.family -eq $Family -and $_.name -eq $Name})
if($taskCase.Count -ne 1){throw 'Expected one case'}
$taskCase=$taskCase[0]
Push-Location "$PSScriptRoot/native_$Family/$Name"
$taskLock=$null
try {
 try {$taskLock=[System.IO.File]::Open((Join-Path (Get-Location) 'run.lock'),[System.IO.FileMode]::OpenOrCreate,[System.IO.FileAccess]::ReadWrite,[System.IO.FileShare]::None)}
 catch [System.IO.IOException] {Write-Output "Already running $Family/$Name";return}
 if(Test-Path simulation.log){
  $taskExisting=Get-Content simulation.log -Raw
  if($taskExisting -match $taskCase.marker -and $taskExisting -match 'PASS CRAM NATIVE SNAPSHOT' -and $taskExisting -match 'Errors: 0' -and $taskExisting -notmatch '\*\* (Error|Fatal|Failure)|Errors: [1-9]'){Write-Output "Previously passed $Family/$Name";return}
 }
 if(-not(Test-Path modelsim.ini)){& "$taskBin/vmap.exe" -c *> vmap.log}
 & "$taskBin/vmap.exe" vdp_work ../vdp_work *>> vmap.log
 $ErrorActionPreference='Continue'
 & "$taskBin/vsim.exe" -c -do 'do run.do' -l simulation.log *> stdout.log
 $taskExit=$LASTEXITCODE
 $ErrorActionPreference='Stop'
 $taskLog=Get-Content simulation.log -Raw
 if($taskExit -or $taskLog -notmatch $taskCase.marker -or $taskLog -notmatch 'PASS CRAM NATIVE SNAPSHOT' -or $taskLog -notmatch 'Errors: 0' -or $taskLog -match '\*\* (Error|Fatal|Failure)|Errors: [1-9]|Failed to open readmem|Failed to open file'){Get-Content simulation.log -Tail 14;throw "Failed $Family/$Name"}
 Write-Output "PASS $Family/$Name"
} finally {if($taskLock){$taskLock.Dispose()};Pop-Location}
