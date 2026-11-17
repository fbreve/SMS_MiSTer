$ErrorActionPreference='Stop'
$taskRoot=(Resolve-Path $PSScriptRoot).Path
$drive='W:'
if(Test-Path "$drive/"){throw "$drive already exists; no mapping changed"}
if(Get-Process quartus_map,quartus_fit,quartus_asm -ErrorAction SilentlyContinue | Where-Object { -not $_.HasExited }){throw 'Another Quartus build is active'}
& subst.exe $drive $taskRoot
if($LASTEXITCODE){throw 'Short-path mapping failed'}
try {
 foreach($taskVariant in @('candidate')) {
  if(Test-Path "$taskRoot/$taskVariant/map.log"){throw 'Do not overwrite an attempted build'}
  Push-Location "$taskRoot/$taskVariant"
  try {
   foreach($taskStage in @('map','fit','asm','sta')) {
    "$taskVariant $taskStage started $(Get-Date -Format o)" | Add-Content "$taskRoot/workflow.log"
    $ErrorActionPreference='Continue'
    if($taskStage -eq 'sta'){& "C:/intelFPGA_lite/17.0/quartus/bin64/quartus_$taskStage.exe" "$drive/$taskVariant/SMS" *> "$taskStage.log"}
    else{& "C:/intelFPGA_lite/17.0/quartus/bin64/quartus_$taskStage.exe" --read_settings_files=on --write_settings_files=off "$drive/$taskVariant/SMS" *> "$taskStage.log"}
    $taskExit=$LASTEXITCODE;$ErrorActionPreference='Stop'
    "$taskVariant $taskStage ended exit=$taskExit $(Get-Date -Format o)" | Add-Content "$taskRoot/workflow.log"
    if($taskExit){throw "STOP $taskVariant $taskStage failed ($taskExit)"}
    Write-Output "PASS $taskVariant $taskStage"
   }
  } finally {Pop-Location}
 }
} finally {& subst.exe $drive /D}
