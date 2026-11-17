$ErrorActionPreference='Stop'
Set-Location $PSScriptRoot
if(Test-Path native_runs){throw 'Refuse overwriting campaign'}
New-Item -ItemType Directory native_runs | Out-Null
$running=@();$next=0;$done=0;$failed=$false
while($next -lt 72 -or $running.Count -gt 0){
 while(!$failed -and $next -lt 72 -and $running.Count -lt 16){
  $log="native_runs/shift$next"
  $proc=Start-Process -FilePath powershell.exe -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-File',"$PSScriptRoot/native_one.ps1",'-Shift',"$next") -WorkingDirectory $PSScriptRoot -WindowStyle Hidden -RedirectStandardOutput "$log.stdout.log" -RedirectStandardError "$log.stderr.log" -PassThru
  $running+=@{process=$proc;shift=$next;log=$log}
  "START shift=$next pid=$($proc.Id) $(Get-Date -Format o)" | Add-Content native_runs/workflow.log
  $next++
 }
 $remaining=@()
 foreach($job in $running){
  $job.process.Refresh();if(!$job.process.HasExited){$remaining+=$job;continue};$job.process.WaitForExit()
  $text=Get-Content "$($job.log).log" -Raw
  $code=if(Test-Path "$($job.log).exitcode"){[int](Get-Content "$($job.log).exitcode" -Raw)}else{-999}
  if($code -ne 0 -or $text -notmatch 'PASS ACC_NATIVE ALL checkpoints=28' -or $text -match 'assertion (failure|error)' -or @(Select-String 'PASS ACC shift=' "$($job.log).log").Count -ne 4){$failed=$true;Write-Output "FAIL shift=$($job.shift) exit=$code"}
  else {$done++;Write-Output "PASS shift=$($job.shift) completed=$done/72"}
  "END shift=$($job.shift) exit=$code $(Get-Date -Format o)" | Add-Content native_runs/workflow.log
 }
 $running=$remaining
 if($failed -and $running.Count -eq 0){throw 'Campaign failed; remaining phases not launched'}
 Start-Sleep -Seconds 2
}
if($done -ne 72){throw 'Incomplete phase coverage'}
Write-Output 'PASS ACCUMULATOR ALL 72 phases x 4 LOADs, six actual PAL sync events per LOAD'
