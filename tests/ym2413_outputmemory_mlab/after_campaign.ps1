$ErrorActionPreference='Stop'
$taskRoot=$PSScriptRoot
$taskLogs=Join-Path $taskRoot 'worktree/tests/ym2413_fullstate/logs'
$taskEmpty=0
while(@(Get-ChildItem "$taskLogs/phase_*.exitcode" -ErrorAction SilentlyContinue).Count -lt 72){
 if(Get-Process ghdl -ErrorAction SilentlyContinue){$taskEmpty=0}else{$taskEmpty++}
 if($taskEmpty -gt 10){throw 'Campaign stopped without 72 completed phases; synthesis remains blocked'}
 Start-Sleep -Seconds 30
}
node "$taskRoot/collect_functional.js" *> "$taskRoot/functional_collect.log"
if($LASTEXITCODE){throw 'Functional collection failed; no synthesis'}
Write-Output 'PASS complete functional campaign gate'
& powershell -NoProfile -ExecutionPolicy Bypass -File "$taskRoot/regress.ps1" *> "$taskRoot/regression_workflow.log"
if($LASTEXITCODE){throw 'Regression suite failed; no synthesis'}
node "$taskRoot/collect_regressions.js" *> "$taskRoot/regression_collect.log"
if($LASTEXITCODE){throw 'Regression collection failed; no synthesis'}
Write-Output 'PASS independent transport/full-state regression gate'
node "$taskRoot/prepare_synthesis.js" *> "$taskRoot/synthesis_prepare.log"
if($LASTEXITCODE){throw 'Synthesis preparation failed'}
& powershell -NoProfile -ExecutionPolicy Bypass -File "$taskRoot/synthesis/map.ps1" *> "$taskRoot/synthesis_workflow.log"
$taskMapExit=$LASTEXITCODE
Set-Content "$taskRoot/synthesis.exitcode" $taskMapExit
Write-Output "Analysis & Synthesis exit=$taskMapExit; no fitter or physical build"
