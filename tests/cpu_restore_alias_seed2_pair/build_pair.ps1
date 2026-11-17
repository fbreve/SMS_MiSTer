$ErrorActionPreference='Stop'
if(Get-Process quartus_sh,quartus_map,quartus_fit,quartus_sta,quartus_asm -ErrorAction SilentlyContinue){throw 'Another Quartus process is active'}
$taskRepoRoot=(Resolve-Path "$PSScriptRoot/../..").Path
if(-not(Test-Path Z:/)){& subst.exe Z: $taskRepoRoot;if($LASTEXITCODE){throw 'Short path mapping failed'}}
$taskMapping=@(& subst.exe)|Where-Object{$_ -match '^Z:\\:'}
if(-not $taskMapping -or ($taskMapping -split ' => ',2)[1].TrimEnd('\') -ne $taskRepoRoot.TrimEnd('\')){throw 'Z: maps another directory'}
foreach($taskName in @('baseline2','candidate2')){
 if(Test-Path "$PSScriptRoot/quartus_$taskName/map.log"){throw 'No duplicate implementation run permitted'}
 Push-Location "$PSScriptRoot/quartus_$taskName"
 try{foreach($taskStage in @('map','fit','asm','sta')){
  "$taskName $taskStage started $(Get-Date -Format o)" | Add-Content "$PSScriptRoot/workflow.log"
  $ErrorActionPreference='Continue'
  if($taskStage -eq 'sta'){& "C:/intelFPGA_lite/17.0/quartus/bin64/quartus_$taskStage.exe" "Z:/tests/cpu_restore_alias_seed2_pair/quartus_$taskName/SMS" *> "$taskStage.log"}
  else{& "C:/intelFPGA_lite/17.0/quartus/bin64/quartus_$taskStage.exe" --read_settings_files=on --write_settings_files=off "Z:/tests/cpu_restore_alias_seed2_pair/quartus_$taskName/SMS" *> "$taskStage.log"}
  $taskExit=$LASTEXITCODE;$ErrorActionPreference='Stop'
  "$taskName $taskStage ended exit=$taskExit $(Get-Date -Format o)" | Add-Content "$PSScriptRoot/workflow.log"
  if($taskExit){throw "STOP $taskName $taskStage failed ($taskExit)"}
  Write-Output "PASS $taskName $taskStage"
 }}finally{Pop-Location}
}
