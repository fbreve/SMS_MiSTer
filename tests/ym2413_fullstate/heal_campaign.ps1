$ErrorActionPreference='Stop'
Set-Location $PSScriptRoot
$sim='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe'
if(Test-Path heal_runs){throw 'Refuse overwriting previous campaign'}
New-Item -ItemType Directory heal_runs | Out-Null
$env:HEAL_FOLLOW='142728'
$running=@();$next=0;$done=0;$failed=$false
while($next -lt 72 -or $running.Count -gt 0){
 while(!$failed -and $next -lt 72 -and $running.Count -lt 4){
  $env:HEAL_SHIFT="$next"
  $taskLog="heal_runs/shift$next"
  $taskProcess=Start-Process -FilePath powershell.exe -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-File',"$PSScriptRoot/heal_one.ps1",'-Shift',"$next") -WorkingDirectory $PSScriptRoot -WindowStyle Hidden -RedirectStandardOutput "$taskLog.stdout.log" -RedirectStandardError "$taskLog.stderr.log" -PassThru
  $running+=@{process=$taskProcess;shift=$next;log=$taskLog}
  "START shift=$next pid=$($taskProcess.Id) $(Get-Date -Format o)" | Add-Content heal_runs/workflow.log
  $next++
 }
 $remaining=@()
 foreach($job in $running){
  $job.process.Refresh()
  if(!$job.process.HasExited){$remaining+=$job;continue}
  $job.process.WaitForExit()
  $content=Get-Content "$($job.log).log" -Raw
  $exitFile="$($job.log).exitcode"
  $code=if(Test-Path $exitFile){[int](Get-Content $exitFile -Raw)}else{-999}
  if($code -ne 0 -or $content -notmatch 'PASS HEAL oracle ALL checkpoints=18' -or $content -match '\*\* (Fatal|Error|Failure):' -or @(Select-String 'PASS HEAL shift=' "$($job.log).log").Count -ne 3){$failed=$true;Write-Output "FAIL shift=$($job.shift) exit=$code"}
  else {$done++;Write-Output "PASS shift=$($job.shift) completed=$done/72"}
  "END shift=$($job.shift) exit=$code $(Get-Date -Format o)" | Add-Content heal_runs/workflow.log
 }
 $running=$remaining
 if($failed -and $running.Count -eq 0){throw 'Campaign failed; no additional cases launched'}
 Start-Sleep -Seconds 2
}
if($done -ne 72){throw 'Incomplete phase coverage'}
Write-Output 'PASS SELFHEALING ALL 72 phases x 3 repeated LOADs, two PAL frames each'
