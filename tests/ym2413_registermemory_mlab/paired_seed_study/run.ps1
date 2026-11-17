$ErrorActionPreference='Stop'
foreach($taskSeed in @(1,3)){
 $taskDir=Join-Path $PSScriptRoot "../physical_seed$taskSeed"
 & powershell -NoProfile -ExecutionPolicy Bypass -File "$taskDir/build.ps1"
 if($LASTEXITCODE){throw "Build failed Seed $taskSeed"}
 & powershell -NoProfile -ExecutionPolicy Bypass -File "$taskDir/query.ps1"
 if($LASTEXITCODE){throw "Query failed Seed $taskSeed"}
 & node "$taskDir/collect.js" *> "$taskDir/collect.log"
 if($LASTEXITCODE){throw "Collector failed Seed $taskSeed"}
 & node "$taskDir/analyze.js" *> "$taskDir/analysis.log"
 if($LASTEXITCODE){throw "Analysis failed Seed $taskSeed"}
 Write-Output "PASS Seed $taskSeed build and analysis"
}
