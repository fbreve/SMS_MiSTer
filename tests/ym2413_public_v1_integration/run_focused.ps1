param([string[]]$Cases=@('compile','protocol','guard_protocol','map','nonfm','validator_stream','early_validator','guard_live'))
$ErrorActionPreference='Stop'
[Diagnostics.Process]::GetCurrentProcess().PriorityClass='Idle'
$taskRoot=$PSScriptRoot
if(Test-Path W:/){throw 'W: occupied'}
& subst.exe W: $taskRoot
if($LASTEXITCODE){throw 'subst failed'}
try {
 Push-Location W:/verification
 try {
  foreach($case in $Cases){
   if(Test-Path "$case.log"){throw "Refusing log overwrite: $case"}
   "START $case $(Get-Date -Format o)" | Add-Content "$taskRoot/focused_workflow.log"
   $ErrorActionPreference='Continue'
   & 'C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe' -c -wlf "$case.wlf" -do "$case.do" -l "$case.log" *> "$case.stdout.log"
   $code=$LASTEXITCODE
   $ErrorActionPreference='Stop'
   $code | Set-Content "$case.exitcode"
   "END $case exit=$code $(Get-Date -Format o)" | Add-Content "$taskRoot/focused_workflow.log"
   $text=Get-Content "$case.log" -Raw
   if($code -ne 0 -or $text -match '\*\* (Fatal|Error|Failure):'){throw "Simulation failed: $case exit=$code"}
   if($case -ne 'compile' -and $text -notmatch 'PASS '){throw "Missing PASS $case"}
   Write-Output "PASS $case"
  }
 } finally {Pop-Location}
} finally {& subst.exe W: /D}


