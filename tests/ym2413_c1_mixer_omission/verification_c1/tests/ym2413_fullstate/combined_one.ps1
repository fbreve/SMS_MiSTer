param([int]$Shift,[int]$FrameEvents=6,[string]$RunDirectory='combined_runs',[string]$Library='ghdl_candidate',[string]$ReferenceLibrary='ghdl_reference',[switch]$TraceCSV,[bool]$LongAllPasses=$false)
$ErrorActionPreference='Stop'
[System.Diagnostics.Process]::GetCurrentProcess().PriorityClass=[System.Diagnostics.ProcessPriorityClass]::Idle
Set-Location $PSScriptRoot
$g="c:\Users\fbrev\Documents\Diversos\Dev\SMS_MiSTer\tests\ym2413_optimized_integration\tools\ghdl6\bin\ghdl.exe"
$log=Join-Path $RunDirectory "shift$Shift"
if(!(Test-Path $RunDirectory)){New-Item -ItemType Directory $RunDirectory | Out-Null}
if(Test-Path "$log.exitcode"){throw 'Refuse overwriting completed simulation'}
# Idle parent gives CreateProcess's default-priority child Windows Low priority.
$longVal=if($LongAllPasses){'true'}else{'false'}
$args=@('-r','--std=08','-fsynopsys','-fexplicit','--work=candidate_work',"--workdir=$Library","-P$ReferenceLibrary",'combined_tb',"-gSHIFT=$Shift","-gFRAME_EVENTS=$FrameEvents","-gLONG_ALL_PASSES=$longVal",'--assert-level=error','--ieee-asserts=disable')
if($TraceCSV){$args+='-gTRACE_CSV=true'}
$p=Start-Process -FilePath $g -ArgumentList $args -WindowStyle Hidden -RedirectStandardOutput "$log.stdout.log" -RedirectStandardError "$log.stderr.log" -PassThru
$null=$p.Handle
$p.Refresh();$checks=0
try {
 while(!$p.HasExited){
  $p.Refresh();if($p.HasExited){break}
  if($p.PriorityClass -ne [System.Diagnostics.ProcessPriorityClass]::Idle){$p.Kill();throw 'Owned GHDL child was not Low priority'}
  $checks++;if($checks -eq 1){"PID=$($p.Id) Priority=$($p.PriorityClass) Executable=$g" | Set-Content "$log.priority.log"}
  Start-Sleep -Seconds 2
 }
 $p.WaitForExit();$p.Refresh();$code=$p.ExitCode
 "VerifiedLowPrioritySamples=$checks" | Add-Content "$log.priority.log"
 Set-Content "$log.exitcode" $code
 if($checks -lt 1){throw 'No child priority verification obtained'}
 Get-Content "$log.stdout.log","$log.stderr.log" | Set-Content "$log.log"
 exit $code
} catch {Set-Content "$log.exitcode" -999;throw}
