$ErrorActionPreference='Stop'
[Diagnostics.Process]::GetCurrentProcess().PriorityClass=[Diagnostics.ProcessPriorityClass]::Idle
$taskExe=(Resolve-Path "$PSScriptRoot/../ym2413_selfhealing_combined/tools/ghdl6/bin/ghdl.exe").Path
Set-Location "$PSScriptRoot/smoke"
function Run-Ghdl([string]$Name,[string[]]$GhdlArgs){
 if(Test-Path "$Name.exitcode"){throw "Refuse duplicate smoke run $Name"}
 $taskProcess=Start-Process -FilePath $taskExe -ArgumentList $GhdlArgs -WindowStyle Hidden -RedirectStandardOutput "$Name.stdout.log" -RedirectStandardError "$Name.stderr.log" -PassThru
 $null=$taskProcess.Handle;$taskSamples=0;$taskWatch=[Diagnostics.Stopwatch]::StartNew()
 try{
  do{
   $taskProcess.Refresh()
   if(!$taskProcess.HasExited){
    if($taskProcess.PriorityClass -ne [Diagnostics.ProcessPriorityClass]::Idle){throw 'GHDL is not Idle'}
    if(!$taskSamples){"PID=$($taskProcess.Id) Priority=$($taskProcess.PriorityClass) ParentPriority=$([Diagnostics.Process]::GetCurrentProcess().PriorityClass)" | Set-Content "$Name.priority.log"}
    $taskSamples++
   }
   if($taskWatch.Elapsed.TotalSeconds -gt 120){throw 'Smoke timeout'}
   if(!$taskProcess.HasExited){Start-Sleep -Milliseconds 10}
  }while(!$taskProcess.HasExited)
  $taskProcess.WaitForExit();$taskCode=$taskProcess.ExitCode
  "VerifiedIdleSamples=$taskSamples elapsed_s=$($taskWatch.Elapsed.TotalSeconds)" | Add-Content "$Name.priority.log"
  Set-Content "$Name.exitcode" $taskCode
  if($taskCode -or !$taskSamples){throw "Smoke failed $Name exit=$taskCode samples=$taskSamples"}
 }catch{if(!$taskProcess.HasExited){$taskProcess.Kill()};throw}
}
foreach($taskLib in @('reference','candidate')){
 Run-Ghdl "compile_$taskLib" @('-a','--std=08','-fsynopsys','-fexplicit',"--work=${taskLib}_work","--workdir=ghdl_$taskLib","$taskLib/registermemory.vhd")
}
Run-Ghdl compile_tb @('-a','--std=08','-fsynopsys','-fexplicit','--work=candidate_work','--workdir=ghdl_candidate','-Pghdl_reference','bank_tb.vhd')
Run-Ghdl bank @('-r','--std=08','-fsynopsys','-fexplicit','--work=candidate_work','--workdir=ghdl_candidate','-Pghdl_reference','bank_tb','--assert-level=error','--ieee-asserts=disable')
Get-Content bank.stdout.log,bank.stderr.log
Write-Output 'PASS limited independent RegisterMemory smoke; four GHDL invocations verified Idle; concurrency 1'
