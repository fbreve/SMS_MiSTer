$ErrorActionPreference='Stop'
Push-Location "$PSScriptRoot/../.."
try {
 while(-not(Test-Path "$PSScriptRoot/quartus_early/sta.log")){Start-Sleep -Seconds 10}
 while(-not((Get-Content "$PSScriptRoot/quartus_early/sta.log" -Raw) -match 'Timing Analyzer was successful')) {
  if((Get-Content "$PSScriptRoot/quartus_early/sta.log" -Raw) -match 'was unsuccessful'){throw 'Early STA failed'}
  Start-Sleep -Seconds 10
 }
 & node "$PSScriptRoot/collect_build.js" early
 if($LASTEXITCODE){throw 'Early result collection failed'}
 & "$PSScriptRoot/analyze_paths.ps1" -Name early
 if($LASTEXITCODE){throw 'Early path extraction failed'}
 # A confirmation is deliberately not automatic: first inspect and identify
 # the exact failing paths as required by the user, then decide on one build.
 & node "$PSScriptRoot/write_report.js"
} finally {Pop-Location}
