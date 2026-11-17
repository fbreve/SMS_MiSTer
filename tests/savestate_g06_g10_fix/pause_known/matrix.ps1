$ErrorActionPreference='Stop'
Set-Location $PSScriptRoot
$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe'
& $bin -c -do 'do compile.do' -l compile.log
if($LASTEXITCODE){throw 'compile failed'}
$cases=Get-Content -Raw cases.json|ConvertFrom-Json
foreach($c in $cases){
 $env:PAUSE_CASE=$c.CASE;$env:PAUSE_DELAY=$c.DELAY;$env:PAUSE_KEEP=0;$env:PAUSE_FULL=0;$env:PAUSE_STALL=0;$env:PAUSE_OFFSET=0;$env:PAUSE_FAST=$c.FAST
 & $bin -c -do 'do case.do' -l "$($c.id).transcript" *> "$($c.id).log"
 $s=Get-Content -Raw "$($c.id).log"
 if($LASTEXITCODE -or $s -match '\*\* (Error|Fatal|Failure)|Errors: [1-9]' -or $s -notmatch 'PASS FIXED'){Get-Content "$($c.id).log" -Tail 16;throw "Failed $($c.id)"}
 Write-Output "PASS $($c.id)"
}
Write-Output "PAUSE MATRIX COMPLETE $($cases.Count) cases"
