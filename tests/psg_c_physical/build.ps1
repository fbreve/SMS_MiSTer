$ErrorActionPreference='Stop'
$taskRoot=(Resolve-Path $PSScriptRoot).Path
$taskToolRoot='C:/intelFPGA_lite/17.0/quartus/bin64'
if(Test-Path Z:/){throw 'Z: is occupied; no mapping changed'}
if(Test-Path "$taskRoot/workflow.log"){throw 'A comparison was already attempted; refusing to overwrite it'}
$taskInitialSta=@(Get-Process quartus_sta -ErrorAction SilentlyContinue | Select-Object Id,CPU,StartTime)
if(Get-Process quartus_map,quartus_fit,quartus_asm,quartus_sh -ErrorAction SilentlyContinue){throw 'An external compiler is active; no build started'}
# A pre-existing idle TimeQuest process is not interrupted. Its identity and
# CPU readings are retained. Never inspect or write its project/database.
$taskInitialSta | ConvertTo-Json | Set-Content "$taskRoot/external_sta_before.json" -Encoding UTF8
& subst.exe Z: $taskRoot
if($LASTEXITCODE){throw 'Short-path mapping failed'}
$taskFailed=$false
try {
 foreach($taskBuild in @('seed1/A','seed1/C','seed2/A','seed2/C')) {
  $taskDir=Join-Path $taskRoot $taskBuild
  foreach($taskForbidden in @('db','incremental_db','output_files','map.log','fit.log','asm.log','sta.log')) {
   if(Test-Path (Join-Path $taskDir $taskForbidden)){throw "Pre-existing output found: $taskBuild/$taskForbidden"}
  }
  & node "$taskRoot/check_inputs.js" $taskBuild
  if($LASTEXITCODE){throw "Frozen inputs differ: $taskBuild"}
  Push-Location $taskDir
  try {
   foreach($taskStage in @('map','fit','asm','sta')) {
    "$taskBuild $taskStage started $(Get-Date -Format o)" | Add-Content "$taskRoot/workflow.log"
    $ErrorActionPreference='Continue'
    if($taskStage -eq 'sta') {
     & "$taskToolRoot/quartus_$taskStage.exe" "Z:/$taskBuild/SMS" *> "$taskStage.log"
    } else {
     & "$taskToolRoot/quartus_$taskStage.exe" --read_settings_files=on --write_settings_files=off "Z:/$taskBuild/SMS" *> "$taskStage.log"
    }
    $taskExit=$LASTEXITCODE
    $ErrorActionPreference='Stop'
    "$taskBuild $taskStage ended exit=$taskExit $(Get-Date -Format o)" | Add-Content "$taskRoot/workflow.log"
    if($taskExit){
     "FAILED $taskBuild $taskStage; no retry, tuning or RTL change. Continuing independent builds." | Add-Content "$taskRoot/workflow.log"
     Write-Output "FAILED $taskBuild $taskStage exit=$taskExit"
     $taskFailed=$true
     break
    }
    Write-Output "PASS $taskBuild $taskStage"
   }
  } finally {Pop-Location}
 }
} finally {
 & subst.exe Z: /D
 @(Get-Process quartus_sta -ErrorAction SilentlyContinue | Select-Object Id,CPU,StartTime) | ConvertTo-Json | Set-Content "$taskRoot/external_sta_after.json" -Encoding UTF8
}
if($taskFailed){exit 1}
