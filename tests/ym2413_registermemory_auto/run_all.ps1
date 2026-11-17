$ErrorActionPreference='Stop'
node "$PSScriptRoot/verify.js"
if($LASTEXITCODE){throw 'Scope check failed'}
& "$PSScriptRoot/compile.ps1"
& "$PSScriptRoot/bank.ps1"
& "$PSScriptRoot/regress.ps1"
& "$PSScriptRoot/launch_campaign.ps1"
node "$PSScriptRoot/collect.js"
if($LASTEXITCODE){throw 'Collection failed'}
