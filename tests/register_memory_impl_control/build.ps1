$ErrorActionPreference='Stop'
$taskRoot=(Resolve-Path $PSScriptRoot).Path
if(Test-Path Z:/){throw 'Z: already exists; no mapping changed'}
if(Get-Process quartus_map,quartus_fit,quartus_sta,quartus_asm -ErrorAction SilentlyContinue | Where-Object { -not $_.HasExited }){throw 'Another Quartus build is active'}
& subst.exe Z: $taskRoot
if($LASTEXITCODE){throw 'Short-path mapping failed'}
try {
 foreach($taskVariant in @('baseline','candidate')) {
  if(Test-Path "$taskRoot/$taskVariant/map.log"){throw 'Do not overwrite an attempted build'}
  Push-Location "$taskRoot/$taskVariant"
  try {
   foreach($taskStage in @('map','fit','asm','sta')) {
    "$taskVariant $taskStage started $(Get-Date -Format o)" | Add-Content "$taskRoot/workflow.log"
    $ErrorActionPreference='Continue'
    if($taskStage -eq 'sta'){& "C:/intelFPGA_lite/17.0/quartus/bin64/quartus_$taskStage.exe" "Z:/$taskVariant/SMS" *> "$taskStage.log"}
    else{& "C:/intelFPGA_lite/17.0/quartus/bin64/quartus_$taskStage.exe" --read_settings_files=on --write_settings_files=off "Z:/$taskVariant/SMS" *> "$taskStage.log"}
    $taskExit=$LASTEXITCODE;$ErrorActionPreference='Stop'
    "$taskVariant $taskStage ended exit=$taskExit $(Get-Date -Format o)" | Add-Content "$taskRoot/workflow.log"
    if($taskExit){throw "STOP $taskVariant $taskStage failed ($taskExit)"}
    Write-Output "PASS $taskVariant $taskStage"
   }
  } finally {Pop-Location}
 }
} finally {& subst.exe Z: /D}
