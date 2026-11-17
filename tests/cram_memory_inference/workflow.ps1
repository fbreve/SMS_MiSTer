$ErrorActionPreference='Stop'
$taskCases=Get-Content "$PSScriptRoot/native_manifest.json" -Raw|ConvertFrom-Json
while($true){
 $taskComplete=0
 foreach($taskCase in $taskCases){
  $taskFile=Join-Path "$PSScriptRoot/../.." ($taskCase.dir+'/simulation.log')
  if(Test-Path $taskFile){
   $taskLog=Get-Content $taskFile -Raw
   if($taskLog -match '\*\* (Error|Fatal|Failure)|Errors: [1-9]'){throw "Failed native case $($taskCase.dir)"}
   if($taskLog -match $taskCase.marker -and $taskLog -match 'Errors: 0'){$taskComplete++}
  }
 }
 if($taskComplete -eq $taskCases.Count){break}
 Start-Sleep -Seconds 15
}
node "$PSScriptRoot/collect_functional.js"
if($LASTEXITCODE){throw 'Functional gate failed; no Quartus build'}
node "$PSScriptRoot/prepare_build.js"
if($LASTEXITCODE){throw 'Build preparation failed'}
& "$PSScriptRoot/build.ps1"
node "$PSScriptRoot/collect_build.js"
if($LASTEXITCODE){throw 'Build collection failed'}
node "$PSScriptRoot/collect_structure.js"
if($LASTEXITCODE){throw 'Structure collection failed'}
& "$PSScriptRoot/analyze_paths.ps1"
Write-Output 'PASS COMPLETE FUNCTIONAL AND PHYSICAL WORKFLOW; review measurements before keep/revert.'
