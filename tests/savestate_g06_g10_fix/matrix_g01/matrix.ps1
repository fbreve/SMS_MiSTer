$ErrorActionPreference='Stop'
Set-Location $PSScriptRoot
$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe'
& $bin -c -do 'do compile.do' -l compile.log
if($LASTEXITCODE){throw 'compile failed'}
$cases=Get-Content -Raw cases.json|ConvertFrom-Json
foreach($c in $cases){
 $label="case_$($c.id)"
 & $bin -c -do "do $label.do" -l "$label.transcript" *> "$label.log"
 $s=Get-Content -Raw "$label.log"
 if($LASTEXITCODE -or $s -match '\*\* (Error|Fatal|Failure)|Errors: [1-9]' -or $s -notmatch 'PASS G01 TRACE'){Get-Content "$label.log" -Tail 16;throw "Failed $label"}
 Write-Output "PASS $label"
}
Write-Output "MATRIX COMPLETE g01 $($cases.Count) cases"
