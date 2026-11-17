param([Parameter(Mandatory=$true)][string]$Family,[Parameter(Mandatory=$true)][string]$Name)
$ErrorActionPreference='Stop';$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem'
$rows=Get-Content "$PSScriptRoot/regression_manifest.json" -Raw|ConvertFrom-Json
$row=@($rows|Where-Object {$_.family -eq $Family -and $_.name -eq $Name})
if($row.Count -ne 1){throw 'Expected exact canonical case'}
$row=$row[0]
Push-Location "$PSScriptRoot/$Family/$Name"
try {
 if(-not(Test-Path modelsim.ini)){& "$bin/vmap.exe" -c *> vmap.log}
 & "$bin/vmap.exe" vdp_work ../vdp_work *>> vmap.log
 $ErrorActionPreference='Continue'
 & "$bin/vsim.exe" -c -do 'do run.do' -l simulation.log *> stdout.log
 $result=$LASTEXITCODE
 $ErrorActionPreference='Stop'
 $log=Get-Content simulation.log -Raw
 if($result -or $log -notmatch $row.marker -or $log -notmatch 'Errors: 0' -or $log -match '\*\* (Error|Fatal|Failure)|Errors: [1-9]|Failed to open readmem|Failed to open file'){Get-Content simulation.log -Tail 20;throw "Failed $Family/$Name"}
 Write-Output "PASS $Family/$Name"
}finally{Pop-Location}
