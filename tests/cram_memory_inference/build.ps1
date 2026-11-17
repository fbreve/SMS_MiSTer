param([ValidateSet('early','confirmation')][string]$Name='early',[ValidateSet('map','fit','asm','sta')][string]$StartStage='map')
$ErrorActionPreference='Stop'
if(Get-Process quartus_sh,quartus_map,quartus_fit,quartus_sta -ErrorAction SilentlyContinue){throw 'Another Quartus process is active'}
$taskRepoRoot=(Resolve-Path "$PSScriptRoot/../..").Path
if(-not(Test-Path Z:/)){& subst.exe Z: $taskRepoRoot;if($LASTEXITCODE){throw 'Short path mapping failed'}}
$taskMapping=@(& subst.exe)|Where-Object{$_ -match '^Z:\\:'}
if(-not $taskMapping -or ($taskMapping -split ' => ',2)[1].TrimEnd('\') -ne $taskRepoRoot.TrimEnd('\')){throw 'Z: maps another directory'}
Push-Location "$PSScriptRoot/quartus_$Name"
try{
 $taskStarted=$false
 foreach($taskStage in @('map','fit','asm','sta')){
  if($taskStage -eq $StartStage){$taskStarted=$true}
  if(-not $taskStarted){continue}
  $ErrorActionPreference='Continue'
  if($taskStage -eq 'sta'){& "C:/intelFPGA_lite/17.0/quartus/bin64/quartus_$taskStage.exe" "Z:/tests/cram_memory_inference/quartus_$Name/SMS" *> "$taskStage.log"}
  else{& "C:/intelFPGA_lite/17.0/quartus/bin64/quartus_$taskStage.exe" --read_settings_files=on --write_settings_files=off "Z:/tests/cram_memory_inference/quartus_$Name/SMS" *> "$taskStage.log"}
  $taskExit=$LASTEXITCODE;$ErrorActionPreference='Stop';if($taskExit){throw "STOP: $Name $taskStage failed ($taskExit)"}
  Write-Output "PASS $Name $taskStage"
  if($taskStage -eq 'fit'){
   $taskFit=Get-Content output_files/SMS.fit.summary -Raw
   if($taskFit -notmatch 'Total RAM Blocks\s*:\s*492\s*/'){throw 'STOP: unexpected M10K count; synthesis showed four palette RAM replicas'}
  }
 }
}finally{Pop-Location}
