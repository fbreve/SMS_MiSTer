$ErrorActionPreference='Stop'
& "$PSScriptRoot/fault/run.ps1" -CompileOnly
& "$PSScriptRoot/fault/run.ps1" -ToolInfo
& "$PSScriptRoot/fault/run.ps1" -Case 15 -Mode 0
& "$PSScriptRoot/fault/run.ps1" -Coherent
Write-Output 'PASS guarded accepted-payload exact fault differential and coherent producer campaign'
