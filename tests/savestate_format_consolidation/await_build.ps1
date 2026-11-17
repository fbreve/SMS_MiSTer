$ErrorActionPreference='Stop'
Push-Location "$PSScriptRoot/../.."
try{
 while($true){
  & node tests/savestate_format_consolidation/validate_gate.js --probe
  if($LASTEXITCODE -eq 0){break}
  Start-Sleep -Seconds 30
 }
 & node tests/savestate_format_consolidation/prepare_build.js experiment
 if($LASTEXITCODE){throw 'Build input preparation failed'}
 & "$PSScriptRoot/build.ps1" -Name experiment
}finally{Pop-Location}
