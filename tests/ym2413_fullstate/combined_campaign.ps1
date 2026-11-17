$ErrorActionPreference='Stop'
Set-Location $PSScriptRoot
if(Test-Path combined_runs){throw 'Refuse overwriting combined campaign'}
New-Item -ItemType Directory combined_runs | Out-Null
$running=@();$next=0;$done=0;$failed=$false
while($next -lt 72 -or $running.Count){
 while(!$failed -and $next -lt 72 -and $running.Count -lt 4){
  $log="combined_runs/shift$next"
  $p=Start-Process powershell.exe -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-File',"$PSScriptRoot/combined_one.ps1",'-Shift',"$next") -WindowStyle Hidden -WorkingDirectory $PSScriptRoot -RedirectStandardOutput "$log.launch.stdout.log" -RedirectStandardError "$log.launch.stderr.log" -PassThru
  $running+=@{p=$p;shift=$next;log=$log}
  "START shift=$next parentPID=$($p.Id) $(Get-Date -Format o)" | Add-Content combined_runs/workflow.log
  $next++
 }
 $left=@()
 foreach($job in $running){
  $job.p.Refresh();if(!$job.p.HasExited){$left+=$job;continue};$job.p.WaitForExit()
  $code=if(Test-Path "$($job.log).exitcode"){[int](Get-Content "$($job.log).exitcode" -Raw)}else{-999}
  $s=if(Test-Path "$($job.log).log"){Get-Content "$($job.log).log" -Raw}else{''}
  if($code -or $s -notmatch 'PASS COMBINED ALL checkpoints=28' -or $s -match 'assertion (failure|error)'){$failed=$true;Write-Output "FAIL shift=$($job.shift) exit=$code"}
  else{$done++;Write-Output "PASS combined shift=$($job.shift) completed=$done/72"}
  "END shift=$($job.shift) exit=$code $(Get-Date -Format o)" | Add-Content combined_runs/workflow.log
 }
 $running=$left
 if($failed -and !$running.Count){throw 'Combined campaign failed; later phases not started'}
 Start-Sleep -Seconds 2
}
if($done -ne 72){throw 'Incomplete combined coverage'}
Write-Output 'PASS COMBINED CAMPAIGN 72 phases x 4 LOADs; at least 115 ms AFTER convergence'
