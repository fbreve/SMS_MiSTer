$ErrorActionPreference='Stop'
$taskRepoRoot=(Resolve-Path "$PSScriptRoot/../..").Path
Push-Location $taskRepoRoot
try{
 while(-not(Test-Path "$PSScriptRoot/functional_gate.json")){
  $ErrorActionPreference='Continue'
  & node "$PSScriptRoot/gate.js" *> "$PSScriptRoot/gate_pending.log"
  $taskGateExit=$LASTEXITCODE
  $ErrorActionPreference='Stop'
  if($taskGateExit -eq 0){break}
  Start-Sleep -Seconds 10
 }
 & node "$PSScriptRoot/prepare_build.js" early
 if($LASTEXITCODE){throw 'Build preparation failed'}
 & "$PSScriptRoot/build.ps1" -Name early
}finally{Pop-Location}
