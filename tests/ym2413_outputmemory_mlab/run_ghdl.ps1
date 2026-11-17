param([string]$Name,[string[]]$GhdlArgs,[int]$TimeoutSeconds=1800)
$ErrorActionPreference='Stop'
if(!('OutputActiveClock' -as [type])){Add-Type -TypeDefinition @'
using System;using System.Runtime.InteropServices;
public static class OutputActiveClock {
 [DllImport("kernel32.dll")] static extern bool QueryUnbiasedInterruptTime(out ulong t);
 public static double Seconds(){ulong t;if(!QueryUnbiasedInterruptTime(out t))throw new Exception("Active clock unavailable");return t/10000000.0;}
}
'@}
$taskActiveStart=[OutputActiveClock]::Seconds()
[Diagnostics.Process]::GetCurrentProcess().PriorityClass=[Diagnostics.ProcessPriorityClass]::Idle
$taskDir=Join-Path $PSScriptRoot 'worktree/tests/ym2413_fullstate'
Set-Location $taskDir
$taskExe=(Resolve-Path "$PSScriptRoot/../ym2413_selfhealing_combined/tools/ghdl6/bin/ghdl.exe").Path
New-Item -ItemType Directory -Force logs | Out-Null
$taskLog=Join-Path $taskDir "logs/$Name"
if(Test-Path "$taskLog.exitcode"){throw "Refuse completed run overwrite $Name"}
$taskP=Start-Process -FilePath $taskExe -ArgumentList $GhdlArgs -WindowStyle Hidden -RedirectStandardOutput "$taskLog.stdout.log" -RedirectStandardError "$taskLog.stderr.log" -PassThru
$null=$taskP.Handle
$taskSamples=0;$taskWatch=[Diagnostics.Stopwatch]::StartNew()
try {
 do {
  $taskP.Refresh()
  if(!$taskP.HasExited){
   if($taskP.PriorityClass -ne [Diagnostics.ProcessPriorityClass]::Idle){throw 'GHDL child priority is not Idle'}
   if(!$taskSamples){"PID=$($taskP.Id) Priority=$($taskP.PriorityClass) ParentPriority=$([Diagnostics.Process]::GetCurrentProcess().PriorityClass)" | Set-Content "$taskLog.priority.log"}
   $taskSamples++
  }
  if(([OutputActiveClock]::Seconds()-$taskActiveStart) -gt $TimeoutSeconds){throw 'GHDL process timeout'}
  if(!$taskP.HasExited){Start-Sleep -Milliseconds 250}
 } while(!$taskP.HasExited)
 $taskP.WaitForExit();$taskCode=$taskP.ExitCode
 "VerifiedIdleSamples=$taskSamples elapsed_s=$($taskWatch.Elapsed.TotalSeconds)" | Add-Content "$taskLog.priority.log"
 if(!$taskSamples){throw 'No explicit priority sample obtained'}
 Set-Content "$taskLog.exitcode" $taskCode
 if($taskCode){Get-Content "$taskLog.stdout.log","$taskLog.stderr.log" -Tail 10;throw "GHDL $Name failed exit=$taskCode"}
} catch {if(!$taskP.HasExited){$taskP.Kill()};throw}
