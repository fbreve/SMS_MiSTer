$ErrorActionPreference='Stop'
while($taskOtherProcesses=Get-Process quartus_sh,quartus_map,quartus_fit,quartus_sta,quartus_asm -ErrorAction SilentlyContinue){
 "Waiting for existing external compiler: $($taskOtherProcesses.ProcessName -join ',') $(Get-Date -Format o)" | Add-Content "$PSScriptRoot/queue.log"
 Start-Sleep -Seconds 15
}
$taskRepoRoot=(Resolve-Path "$PSScriptRoot/../..").Path
if(Test-Path Z:/){throw 'Z: already exists; no mapping changed'}
if(Test-Path "$PSScriptRoot/source/map.log"){throw 'Historical implementation already attempted; no overwrite/retry permitted'}
& subst.exe Z: $taskRepoRoot
if($LASTEXITCODE){throw 'Short-path mapping failed'}
try {
 Push-Location "$PSScriptRoot/source"
 try {
  foreach($taskStage in @('map','fit','asm','sta')) {
   "$taskStage started $(Get-Date -Format o)" | Add-Content "$PSScriptRoot/workflow.log"
   $ErrorActionPreference='Continue'
   if($taskStage -eq 'sta'){& "C:/intelFPGA_lite/17.0/quartus/bin64/quartus_$taskStage.exe" 'Z:/tests/historical_baseline_4d8506a/source/SMS' *> "$taskStage.log"}
   else{& "C:/intelFPGA_lite/17.0/quartus/bin64/quartus_$taskStage.exe" --read_settings_files=on --write_settings_files=off 'Z:/tests/historical_baseline_4d8506a/source/SMS' *> "$taskStage.log"}
   $taskExit=$LASTEXITCODE;$ErrorActionPreference='Stop'
   "$taskStage ended exit=$taskExit $(Get-Date -Format o)" | Add-Content "$PSScriptRoot/workflow.log"
   if($taskExit){throw "STOP historical $taskStage failed ($taskExit); no correction attempted"}
   Write-Output "PASS historical $taskStage"
  }
 } finally {Pop-Location}
} finally {& subst.exe Z: /D}
