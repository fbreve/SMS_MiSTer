$ErrorActionPreference='Stop'
$taskRoot=(Resolve-Path $PSScriptRoot).Path
$taskGate=Get-Content "$taskRoot/synthesis_gate.json" -Raw | ConvertFrom-Json
if(!$taskGate.PASS){throw 'MLAB synthesis gate not passed'}
if(Test-Path Z:/){throw 'Z: occupied'}
if(Get-Process quartus_map,quartus_fit,quartus_asm,quartus_sh -ErrorAction SilentlyContinue){throw 'Compilation active'}
if(Test-Path "$taskRoot/candidate/fit.log"){throw 'Refuse additional fitter run'}
node "$taskRoot/check_inputs.js"
if($LASTEXITCODE){throw 'Frozen inputs changed'}
& subst.exe Z: $taskRoot
if($LASTEXITCODE){throw 'Mapping failed'}
try{
 Push-Location "$taskRoot/candidate"
 try{
  foreach($taskStage in @('fit','asm','sta')){
   "candidate $taskStage started $(Get-Date -Format o)" | Add-Content "$taskRoot/workflow.log"
   $ErrorActionPreference='Continue'
   if($taskStage -eq 'sta'){& "C:/intelFPGA_lite/17.0/quartus/bin64/quartus_$taskStage.exe" Z:/candidate/SMS *> "$taskStage.log"}
   else{& "C:/intelFPGA_lite/17.0/quartus/bin64/quartus_$taskStage.exe" --read_settings_files=on --write_settings_files=off Z:/candidate/SMS *> "$taskStage.log"}
   $taskExit=$LASTEXITCODE;$ErrorActionPreference='Stop'
   "candidate $taskStage ended exit=$taskExit $(Get-Date -Format o)" | Add-Content "$taskRoot/workflow.log"
   if($taskExit){throw "Stop $taskStage exit=$taskExit; no retry"}
   Write-Output "PASS candidate $taskStage"
  }
 }finally{Pop-Location}
 node "$taskRoot/check_inputs.js"
 if($LASTEXITCODE){throw 'Frozen inputs changed'}
}finally{& subst.exe Z: /D}
