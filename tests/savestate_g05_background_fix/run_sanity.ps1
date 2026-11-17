param([string]$Fixture)
$ErrorActionPreference='Stop'
Push-Location (Join-Path $PSScriptRoot $Fixture)
try {
 $bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem'
 & "$bin/vmap.exe" -c | Out-Null
 & "$bin/vsim.exe" -c -do 'do compile.do' -l compile.log *> compile_stdout.log
 if((Get-Content -Raw compile.log) -match '\*\* (Error|Fatal|Failure)|Errors: [1-9]'){throw 'Compile failure'}
 $cases=Get-Content -Raw cases.json | ConvertFrom-Json
 foreach($case in $cases){
  & "$bin/vsim.exe" -c -do "do $($case.id).do" -l "$($case.id).log" *> "$($case.id)_stdout.log"
  $s=Get-Content -Raw "$($case.id).log"
  if($s -match '\*\* (Error|Fatal|Failure)|Errors: [1-9]' -or $s -notmatch 'PASS (G01 TRACE|F16 fixed|FIXED case)' -or $s -notmatch '# End time:'){throw "Failed $Fixture/$($case.id)"}
  Write-Output "PASS $Fixture/$($case.id)"
 }
}finally{Pop-Location}
