$ErrorActionPreference='Stop'
$taskRoot=(Resolve-Path $PSScriptRoot).Path
if(Test-Path Z:/){throw 'Z: occupied; no mapping changed'}
if(Get-Process quartus_map,quartus_fit,quartus_asm,quartus_sh -ErrorAction SilentlyContinue){throw 'Another Quartus compilation is active'}
Get-Process quartus_sta -ErrorAction SilentlyContinue | Select-Object Id,ProcessName,CPU,StartTime | ConvertTo-Json | Set-Content "$taskRoot/preexisting_sta.json"
& subst.exe Z: $taskRoot
if($LASTEXITCODE){throw 'Short-path mapping failed'}
try {
 foreach($taskVariant in @('baseline','candidate')) {
  node "$taskRoot/check_inputs.js" $taskVariant
  if($LASTEXITCODE){throw 'Input validation failed'}
  foreach($taskForbidden in @('db','incremental_db','output_files','map.log')){if(Test-Path "$taskRoot/$taskVariant/$taskForbidden"){throw "Not a fresh build: $taskVariant/$taskForbidden"}}
  Push-Location "$taskRoot/$taskVariant"
  try {
   foreach($taskStage in @('map','fit','asm','sta')) {
    "$taskVariant $taskStage started $(Get-Date -Format o)" | Add-Content "$taskRoot/workflow.log"
    $ErrorActionPreference='Continue'
    if($taskStage -eq 'sta'){& "C:/intelFPGA_lite/17.0/quartus/bin64/quartus_$taskStage.exe" "Z:/$taskVariant/SMS" *> "$taskStage.log"}
    else {& "C:/intelFPGA_lite/17.0/quartus/bin64/quartus_$taskStage.exe" --read_settings_files=on --write_settings_files=off "Z:/$taskVariant/SMS" *> "$taskStage.log"}
    $taskExit=$LASTEXITCODE;$ErrorActionPreference='Stop'
    "$taskVariant $taskStage ended exit=$taskExit $(Get-Date -Format o)" | Add-Content "$taskRoot/workflow.log"
    if($taskExit){throw "STOP $taskVariant $taskStage failed ($taskExit); no retry or source changes"}
    Write-Output "PASS $taskVariant $taskStage"
   }
  } finally {Pop-Location}
 }
 node "$taskRoot/check_inputs.js"
} finally {& subst.exe Z: /D}
