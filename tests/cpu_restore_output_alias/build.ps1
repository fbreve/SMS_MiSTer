param([ValidateSet('candidate1','baseline2','candidate2')][string]$Name='candidate1')
$ErrorActionPreference='Stop'
if(Get-Process quartus_sh,quartus_map,quartus_fit,quartus_sta -ErrorAction SilentlyContinue){throw 'Another Quartus process is active'}
$taskRepoRoot=(Resolve-Path "$PSScriptRoot/../..").Path
if(-not(Test-Path Z:/)){& subst.exe Z: $taskRepoRoot;if($LASTEXITCODE){throw 'Short path mapping failed'}}
$taskMapping=@(& subst.exe)|Where-Object{$_ -match '^Z:\\:'}
if(-not $taskMapping -or ($taskMapping -split ' => ',2)[1].TrimEnd('\') -ne $taskRepoRoot.TrimEnd('\')){throw 'Z: maps another directory'}
Push-Location "$PSScriptRoot/quartus_$Name"
try{foreach($taskStage in @('map','fit','asm','sta')){
 $ErrorActionPreference='Continue'
 if($taskStage -eq 'sta'){& "C:/intelFPGA_lite/17.0/quartus/bin64/quartus_$taskStage.exe" "Z:/tests/cpu_restore_output_alias/quartus_$Name/SMS" *> "$taskStage.log"}
 else{& "C:/intelFPGA_lite/17.0/quartus/bin64/quartus_$taskStage.exe" --read_settings_files=on --write_settings_files=off "Z:/tests/cpu_restore_output_alias/quartus_$Name/SMS" *> "$taskStage.log"}
 $taskExit=$LASTEXITCODE;$ErrorActionPreference='Stop';if($taskExit){throw "STOP $Name $taskStage failed ($taskExit)"}
 Write-Output "PASS $Name $taskStage"
}}finally{Pop-Location}
