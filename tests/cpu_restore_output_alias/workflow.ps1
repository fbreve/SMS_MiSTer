$ErrorActionPreference='Stop'
function Stage([string]$Text){[IO.File]::WriteAllText((Join-Path $PSScriptRoot 'workflow_stage.txt'),$Text);Write-Output $Text}
Stage 'Waiting for all40 source-bound functional cases; no Quartus started'
while($true){
 $taskStatus=(& node "$PSScriptRoot/collect_functional.js"|Out-String|ConvertFrom-Json)
 if($LASTEXITCODE){throw 'Functional evidence/source check failed'}
 if($taskStatus.failed.Count){throw ('STOP functional failures: '+($taskStatus.failed -join ', '))}
 if(-not $taskStatus.pending.Count){break}
 Start-Sleep -Seconds 5
}
& node "$PSScriptRoot/collect_functional.js" --final
if($LASTEXITCODE){throw 'Final functional gate failed'}
Stage 'All40 functional cases passed; preparing source-isolated seed1 candidate'
& node "$PSScriptRoot/prepare_build.js" candidate1
if($LASTEXITCODE){throw 'Candidate1 provenance failed'}
& "$PSScriptRoot/build.ps1" -Name candidate1
& node "$PSScriptRoot/collect_build.js" candidate1
if($LASTEXITCODE){throw 'Candidate1 resource/source check failed'}
& "$PSScriptRoot/query.ps1" -Name candidate1
& node "$PSScriptRoot/physical_gate.js" candidate1
if($LASTEXITCODE){throw 'Candidate1 register proof failed'}
$taskFirst=Get-Content "$PSScriptRoot/candidate1_results.json" -Raw|ConvertFrom-Json
if(-not $taskFirst.physicalGate){Stage 'REJECTED seed1 physical gate; no second seed; production unchanged';return}
Stage 'Seed1 favorable; building paired seed2 baseline and candidate'
foreach($taskName in @('baseline2','candidate2')){
 & node "$PSScriptRoot/prepare_build.js" $taskName
 if($LASTEXITCODE){throw "Provenance failed $taskName"}
 & "$PSScriptRoot/build.ps1" -Name $taskName
 & node "$PSScriptRoot/collect_build.js" $taskName
 if($LASTEXITCODE){throw "Resource/source check failed $taskName"}
 & "$PSScriptRoot/query.ps1" -Name $taskName
}
& node "$PSScriptRoot/physical_gate.js" candidate2
if($LASTEXITCODE){throw 'Paired seed2 register proof failed'}
$taskSecond=Get-Content "$PSScriptRoot/candidate2_results.json" -Raw|ConvertFrom-Json
if($taskSecond.physicalGate){Stage 'QUALIFIED isolated experiment in both paired seeds; production unchanged'}
else{Stage 'REJECTED paired seed2 physical gate; production unchanged'}
