$ErrorActionPreference='Stop'
$taskNext=0;$taskRunning=@();$taskDone=0;$taskFailed=$false
while($taskNext -lt 72 -or $taskRunning.Count){
 $taskPilot=$null
 $taskPilotLog="$PSScriptRoot/worktree/tests/ym2413_fullstate/logs/pilot_0"
 if((Test-Path "$taskPilotLog.priority.log") -and !(Test-Path "$taskPilotLog.exitcode")){
  $taskPilotText=Get-Content "$taskPilotLog.priority.log" -Raw
  if($taskPilotText -match 'PID=(\d+)'){$taskPilot=Get-Process -Id ([int]$Matches[1]) -ErrorAction SilentlyContinue}
 }
 $taskLimit=if($taskPilot){3}else{4}
 while(!$taskFailed -and $taskNext -lt 72 -and $taskRunning.Count -lt $taskLimit){
  $taskP=Start-Process powershell.exe -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-File',"$PSScriptRoot/one.ps1",'-Shift',"$taskNext") -WindowStyle Hidden -WorkingDirectory $PSScriptRoot -RedirectStandardOutput "$PSScriptRoot/phase$taskNext.launch.log" -RedirectStandardError "$PSScriptRoot/phase$taskNext.launch.error.log" -PassThru
  $taskRunning+=@{p=$taskP;shift=$taskNext};"START shift=$taskNext PID=$($taskP.Id) $(Get-Date -Format o)" | Add-Content "$PSScriptRoot/workflow.log";$taskNext++
 }
 $taskLeft=@()
 foreach($taskJob in $taskRunning){
  $taskJob.p.Refresh();if(!$taskJob.p.HasExited){$taskLeft+=$taskJob;continue};$taskJob.p.WaitForExit()
  $taskLog="$PSScriptRoot/worktree/tests/ym2413_fullstate/logs/phase_$($taskJob.shift)"
  $taskCode=if(Test-Path "$taskLog.exitcode"){[int](Get-Content "$taskLog.exitcode" -Raw)}else{-999}
  if($taskCode -or !(Test-Path "$taskLog.stdout.log") -or !(Select-String -LiteralPath "$taskLog.stdout.log" -SimpleMatch 'PASS OUTPUT ALL loads=2' -Quiet)){$taskFailed=$true;Write-Output "FAIL phase $($taskJob.shift)"}
  else {$taskDone++;Write-Output "PASS phase=$($taskJob.shift) completed=$taskDone/72"}
  "END shift=$($taskJob.shift) exit=$taskCode $(Get-Date -Format o)" | Add-Content "$PSScriptRoot/workflow.log"
 }
 $taskRunning=$taskLeft
 if($taskFailed -and !$taskRunning.Count){throw 'Campaign failed; later phases not launched'}
 Start-Sleep -Seconds 2
}
if($taskDone -ne 72){throw 'Incomplete phase coverage'}
Write-Output 'PASS OUTPUT CAMPAIGN phases=72 loads=144 exact=TRUE followup_per_load>=115ms'
