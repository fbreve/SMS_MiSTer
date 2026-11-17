$ErrorActionPreference='Stop'
$taskRoot=(Resolve-Path $PSScriptRoot).Path
if(Test-Path Z:/){throw 'Z: occupied'}
if(Get-Process quartus_map,quartus_fit,quartus_asm,quartus_sh -ErrorAction SilentlyContinue){throw 'Compilation active'}
node "$taskRoot/report_hashes.js" record
if($LASTEXITCODE){throw 'Report identity capture failed'}
& subst.exe Z: $taskRoot
if($LASTEXITCODE){throw 'Mapping failed'}
try {
 foreach($taskVariant in @('baseline','candidate')) {
  if(!(Select-String -LiteralPath "$taskRoot/workflow.log" -SimpleMatch "$taskVariant sta ended exit=0" -Quiet)){continue}
  if(Test-Path "$taskRoot/$taskVariant/physical_setup.rpt"){throw 'Do not overwrite path evidence'}
  Push-Location "$taskRoot/$taskVariant"
  try {
   $ErrorActionPreference='Continue'
   & C:/intelFPGA_lite/17.0/quartus/bin64/quartus_sh.exe -t Z:/settings.tcl "Z:/$taskVariant" *> settings.log
   $settingsExit=$LASTEXITCODE
   & C:/intelFPGA_lite/17.0/quartus/bin64/quartus_sta.exe -t Z:/paths.tcl "Z:/$taskVariant/SMS" *> paths.log
   $pathsExit=$LASTEXITCODE;$ErrorActionPreference='Stop'
   if($settingsExit -or $pathsExit){throw "Read-only queries failed $taskVariant settings=$settingsExit paths=$pathsExit"}
   Write-Output "PASS settings/paths $taskVariant"
  } finally {Pop-Location}
 }
 node "$taskRoot/check_inputs.js"
 node "$taskRoot/report_hashes.js" check
 if($LASTEXITCODE){throw 'Native report identity changed'}
} finally {& subst.exe Z: /D}
