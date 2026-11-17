param([int]$TaskPid,[string]$Label)
$ErrorActionPreference='Stop'
[Diagnostics.Process]::GetCurrentProcess().PriorityClass=[Diagnostics.ProcessPriorityClass]::Idle
$taskP=Get-Process -Id $TaskPid
$null=$taskP.Handle
$taskLog=Join-Path $PSScriptRoot "logs/$Label"
& "$PSScriptRoot/check_process_tree.ps1"
$taskSamples=0;$taskWatch=[Diagnostics.Stopwatch]::StartNew()
do{
 $taskP.Refresh()
 if(!$taskP.HasExited){if($taskP.PriorityClass -ne 'Idle'){throw 'Owned simulation not Idle'};$taskSamples++}
 if($taskWatch.Elapsed.TotalMinutes -gt 30){throw 'Resume-monitor timeout'}
 if(!$taskP.HasExited){Start-Sleep -Milliseconds 250}
}while(!$taskP.HasExited)
$taskP.WaitForExit()
"resumed_after_CIM_denial samples=$taskSamples exit=$($taskP.ExitCode)"|Add-Content "$taskLog.priority"
if($taskP.ExitCode -ne 0){throw 'Owned simulation failed'}
if(!(Select-String -Path "$taskLog.out" -Pattern 'PASS FAULT_PROBE')){throw 'Missing bounded probe completion'}
Write-Output "PASS resumed $Label"
