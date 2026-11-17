$ErrorActionPreference='Stop'
$taskRoot=(Resolve-Path $PSScriptRoot).Path
if(Test-Path W:/){throw 'W: occupied; no mapping changed'}
if(Get-Process quartus_map,quartus_fit,quartus_asm,quartus_sh -ErrorAction SilentlyContinue){throw 'Another Quartus compilation is active'}
& subst.exe W: $taskRoot
if($LASTEXITCODE){throw 'Short-path mapping failed'}
try {
 foreach($taskVariant in @('b1','c1')) {
  foreach($taskForbidden in @('db','incremental_db','output_files','map.log')){if(Test-Path "$taskRoot/$taskVariant/$taskForbidden"){throw "Not a fresh build: $taskVariant/$taskForbidden"}}
  Push-Location "$taskRoot/$taskVariant"
  try {
   "$taskVariant map started $(Get-Date -Format o)" | Add-Content "$taskRoot/workflow.log"
   $ErrorActionPreference='Continue'
   & "C:/intelFPGA_lite/17.0/quartus/bin64/quartus_map.exe" --read_settings_files=on --write_settings_files=off "W:/$taskVariant/SMS" *> "map.log"
   $taskExit=$LASTEXITCODE;$ErrorActionPreference='Stop'
   "$taskVariant map ended exit=$taskExit $(Get-Date -Format o)" | Add-Content "$taskRoot/workflow.log"
   if($taskExit){throw "STOP $taskVariant map failed ($taskExit)"}
   Write-Output "PASS $taskVariant map"
  } finally {Pop-Location}
 }
} finally {& subst.exe W: /D}
