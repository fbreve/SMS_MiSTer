param(
 [Parameter(Mandatory=$true)][int]$StartShift,
 [Parameter(Mandatory=$true)][int]$EndShift,
 [string]$RunDirectory='combined_runs',
 [int]$MaxConcurrent=2
)
$ErrorActionPreference='Stop'
[System.Diagnostics.Process]::GetCurrentProcess().PriorityClass=[System.Diagnostics.ProcessPriorityClass]::Idle
Set-Location $PSScriptRoot
if(!(Test-Path $RunDirectory)){New-Item -ItemType Directory $RunDirectory | Out-Null}
if($MaxConcurrent -lt 1 -or $MaxConcurrent -gt 2){throw 'MaxConcurrent must be 1 or 2'}

$total=$EndShift - $StartShift + 1
$running=@()
$next=$StartShift
$done=0
$failed=$false

while($next -le $EndShift -or $running.Count){
 while(!$failed -and $next -le $EndShift -and $running.Count -lt $MaxConcurrent){
  $log=Join-Path $RunDirectory "shift$next"
  if(Test-Path "$log.exitcode"){
   $code=[int](Get-Content "$log.exitcode" -Raw)
   $s=if(Test-Path "$log.log"){Get-Content "$log.log" -Raw}else{''}
   if($code -eq 0 -and $s -match 'PASS COMBINED ALL checkpoints=28' -and $s -notmatch 'assertion (failure|error)'){
    $done++
    Write-Output "SKIP already-passed shift=$next completed=$done/$total"
    $next++
    continue
   } else {
    throw "Existing failed or incomplete run for shift=$next (exit=$code)"
   }
  }
  $p=Start-Process powershell.exe -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-File',"$PSScriptRoot/combined_one.ps1",'-Shift',"$next",'-RunDirectory',$RunDirectory) -WindowStyle Hidden -WorkingDirectory $PSScriptRoot -RedirectStandardOutput "$log.launch.stdout.log" -RedirectStandardError "$log.launch.stderr.log" -PassThru
  $running+=@{p=$p;shift=$next;log=$log}
  "START shift=$next parentPID=$($p.Id) $(Get-Date -Format o)" | Add-Content (Join-Path $RunDirectory 'workflow.log')
  $next++
 }
 $left=@()
 foreach($job in $running){
  $job.p.Refresh()
  if(!$job.p.HasExited){$left+=$job;continue}
  $job.p.WaitForExit()
  $code=if(Test-Path "$($job.log).exitcode"){[int](Get-Content "$($job.log).exitcode" -Raw)}else{-999}
  $s=if(Test-Path "$($job.log).log"){Get-Content "$($job.log).log" -Raw}else{''}
  if($code -or $s -notmatch 'PASS COMBINED ALL checkpoints=28' -or $s -match 'assertion (failure|error)'){
   $failed=$true
   Write-Output "FAIL shift=$($job.shift) exit=$code"
  } else {
   $done++
   Write-Output "PASS combined shift=$($job.shift) completed=$done/$total"
  }
  "END shift=$($job.shift) exit=$code $(Get-Date -Format o)" | Add-Content (Join-Path $RunDirectory 'workflow.log')
 }
 $running=$left
 if($failed -and !$running.Count){throw "Batch $StartShift..$EndShift failed; later phases not started"}
 if($running.Count){Start-Sleep -Seconds 2}
}
if($done -ne $total){throw "Incomplete batch coverage: $done/$total"}
Write-Output "PASS BATCH shifts=$StartShift..$EndShift completed=$done/$total"

