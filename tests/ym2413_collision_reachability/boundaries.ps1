$ErrorActionPreference='Stop'
foreach($taskCase in @(0,1)){
 & "$PSScriptRoot/run.ps1" -Case $taskCase -Mode 1 -Gap 0
 & "$PSScriptRoot/run.ps1" -Case $taskCase -Mode 2 -Gap 14
}
