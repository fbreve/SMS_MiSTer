param([string]$QuartusBin = $env:QUARTUS_BIN)
$ErrorActionPreference='Stop'
if(-not $QuartusBin) { throw 'Set QUARTUS_BIN to the Quartus 17.0.2 bin64 directory' }
$taskRoot=Join-Path $PSScriptRoot 'physical'
if(Test-Path Z:/) { throw 'Z: is already in use; no mapping changed' }
if(Get-Process quartus_map,quartus_fit,quartus_asm -ErrorAction SilentlyContinue) { throw 'Another implementation is active' }
$taskVersion=(& (Join-Path $QuartusBin 'quartus_sh.exe') --version | Out-String)
if($taskVersion -notmatch '17.0.2 Build 602') { throw 'Wrong Quartus version' }
$taskTools=@{}
foreach($taskTool in @('sh','map','fit','asm','sta','eda')) {
 $taskTools["quartus_$taskTool"]=(Get-FileHash (Join-Path $QuartusBin "quartus_$taskTool.exe") -Algorithm SHA256).Hash.ToLower()
}
@{version=$taskVersion.Trim();binaries=$taskTools;preexistingProcesses=@(Get-Process quartus,quartus_sta -ErrorAction SilentlyContinue | Select-Object ProcessName,Id,StartTime,CPU)} | ConvertTo-Json -Depth 6 | Set-Content -Encoding UTF8 (Join-Path $taskRoot 'tool_identity.json')
foreach($taskSeed in @(1,2)) {
 $taskSeedRoot=Join-Path $taskRoot "runs/seed$taskSeed"
 & subst.exe Z: $taskSeedRoot
 if($LASTEXITCODE) { throw 'Short-path mapping failed' }
 try {
  foreach($taskVariant in @('baseline','candidate')) {
   $taskDir=Join-Path $taskSeedRoot $taskVariant
   if(Test-Path "$taskDir/map.log") { throw 'Never overwrite an attempted build' }
   if((Test-Path "$taskDir/db") -or (Test-Path "$taskDir/incremental_db")) { throw 'Build must start without databases' }
   Push-Location $taskDir
   try {
    foreach($taskStage in @('map','fit','asm','sta')) {
     "seed$taskSeed $taskVariant $taskStage started $(Get-Date -Format o)" | Add-Content "$taskRoot/workflow.log"
     $ErrorActionPreference='Continue'
     if($taskStage -eq 'sta') { & (Join-Path $QuartusBin "quartus_$taskStage.exe") "Z:/$taskVariant/SMS" *> "$taskStage.log" }
     else { & (Join-Path $QuartusBin "quartus_$taskStage.exe") --read_settings_files=on --write_settings_files=off "Z:/$taskVariant/SMS" *> "$taskStage.log" }
     $taskExit=$LASTEXITCODE; $ErrorActionPreference='Stop'
     "seed$taskSeed $taskVariant $taskStage ended exit=$taskExit $(Get-Date -Format o)" | Add-Content "$taskRoot/workflow.log"
     if($taskExit) { throw "seed$taskSeed $taskVariant $taskStage failed ($taskExit)" }
     Write-Output "PASS seed$taskSeed $taskVariant $taskStage"
    }
   } finally { Pop-Location }
  }
 } finally { & subst.exe Z: /D }
}
