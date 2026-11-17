$ErrorActionPreference='Stop'
$taskRoot=(Resolve-Path $PSScriptRoot).Path
if(Test-Path Z:/){throw 'Z: occupied'}
if(Get-Process quartus_map,quartus_fit,quartus_asm,quartus_sh -ErrorAction SilentlyContinue){throw 'Another compilation active'}
node "$taskRoot/check_inputs.js"
if($LASTEXITCODE){throw 'Frozen inputs failed'}
foreach($taskForbidden in @('db','incremental_db','output_files','map.log')){if(Test-Path "$taskRoot/candidate/$taskForbidden"){throw 'Not fresh isolated build'}}
& subst.exe Z: $taskRoot
if($LASTEXITCODE){throw 'Mapping failed'}
try{
 Push-Location "$taskRoot/candidate"
 try{
  "candidate map started $(Get-Date -Format o)" | Add-Content "$taskRoot/workflow.log"
  $ErrorActionPreference='Continue'
  & C:/intelFPGA_lite/17.0/quartus/bin64/quartus_map.exe --read_settings_files=on --write_settings_files=off Z:/candidate/SMS *> map.log
  $taskExit=$LASTEXITCODE;$ErrorActionPreference='Stop'
  "candidate map ended exit=$taskExit $(Get-Date -Format o)" | Add-Content "$taskRoot/workflow.log"
  Write-Output "Analysis & Synthesis exit=$taskExit; stop for inference inspection"
 }finally{Pop-Location}
 node "$taskRoot/check_inputs.js"
 if($LASTEXITCODE){throw 'Frozen inputs changed'}
 if($taskExit){exit $taskExit}
}finally{& subst.exe Z: /D}
