param([switch]$CompileOnly,[switch]$Coherent,[switch]$ToolInfo,[int]$Case=-1,[int]$Mode=-1,[int]$Follow=4096,[int]$Gap=1)
$ErrorActionPreference='Stop'
Set-Location $PSScriptRoot
[Diagnostics.Process]::GetCurrentProcess().PriorityClass=[Diagnostics.ProcessPriorityClass]::Idle
$taskExe=(Resolve-Path '../ym2413_selfhealing_combined/tools/ghdl6/bin/ghdl.exe').Path
New-Item -ItemType Directory -Force logs | Out-Null
function Run-Ghdl([string]$Label,[string[]]$Arguments){
 if(@(Get-Process ghdl -ErrorAction SilentlyContinue).Count -ge 2){throw 'Concurrency limit: maximum two GHDL processes'}
 $taskLog=Join-Path $PSScriptRoot "logs/$Label"
 $taskP=Start-Process -FilePath $taskExe -ArgumentList $Arguments -WindowStyle Hidden -PassThru -RedirectStandardOutput "$taskLog.out" -RedirectStandardError "$taskLog.err"
 $null=$taskP.Handle;$taskSamples=0;$taskTimer=[Diagnostics.Stopwatch]::StartNew()
 do{
  $taskP.Refresh()
  if(!$taskP.HasExited){if($taskP.PriorityClass -ne 'Idle'){$taskP.Kill();throw 'GHDL not Idle'};$taskSamples++;if($taskSamples -eq 1){
   "PID=$($taskP.Id) Priority=$($taskP.PriorityClass) Parent=Idle"|Set-Content "$taskLog.priority"
   & "$PSScriptRoot/check_process_tree.ps1" | Out-Null
   "ProcessTree=Toolhelp32_verified_Idle"|Add-Content "$taskLog.priority"
  }}
  if($taskTimer.Elapsed.TotalSeconds -gt 1800){$taskP.Kill();throw 'GHDL timeout'}
  if(!$taskP.HasExited){Start-Sleep -Milliseconds 100}
 }while(!$taskP.HasExited)
 $taskP.WaitForExit();"samples=$taskSamples exit=$($taskP.ExitCode)"|Add-Content "$taskLog.priority"
 if($taskP.ExitCode -ne 0){Get-Content "$taskLog.out","$taskLog.err" -Tail 12;throw "Failed $Label"}
 if($taskSamples -eq 0){throw 'No priority observation'}
 Write-Output "PASS $Label"
}
$taskFlags=@('--std=08','-fsynopsys','-fexplicit')
if($ToolInfo){Run-Ghdl version @('--version');Run-Ghdl config @('--disp-config');Get-FileHash $taskExe -Algorithm SHA256|Format-List|Out-File logs/tool_sha256.txt
}elseif($CompileOnly){
 $taskNames='vm2413 slotcounter voicerom voicememory registermemory attacktable envelopememory envelopegenerator phasememory phasegenerator sinetable operator feedbackmemory outputmemory lineartable outputgenerator temporalmixer controller opll'.Split(' ')
 foreach($taskLib in @('reference','candidate')){
  New-Item -ItemType Directory -Force "ghdl_$taskLib"|Out-Null
  foreach($taskName in $taskNames){Run-Ghdl "compile_${taskLib}_$taskName" (@('-a')+$taskFlags+@("--work=${taskLib}_work","--workdir=ghdl_$taskLib","$taskLib/$taskName.vhd"))}
  Run-Ghdl "compile_${taskLib}_wrapper" (@('-a')+$taskFlags+@("--work=${taskLib}_work","--workdir=ghdl_$taskLib","${taskLib}_wrapper.vhd"))
 }
 Run-Ghdl compile_tb (@('-a')+$taskFlags+@('--work=candidate_work','--workdir=ghdl_candidate','-Pghdl_reference','reach_tb.vhd'))
}elseif($Coherent){Run-Ghdl coherent (@('-r')+$taskFlags+@('--work=candidate_work','--workdir=ghdl_candidate','-Pghdl_reference','reach_tb','-gTESTCASE=10','--assert-level=error','--ieee-asserts=disable'))
}else{
 $taskCases=if($Case -ge 0){@($Case)}else{0..3};$taskModes=if($Mode -ge 0){@($Mode)}else{0..5}
 foreach($taskCase in $taskCases){foreach($taskMode in $taskModes){$taskSuffix=if($Gap -eq 1){''}else{"_gap$Gap"};Run-Ghdl "case${taskCase}_mode${taskMode}${taskSuffix}" (@('-r')+$taskFlags+@('--work=candidate_work','--workdir=ghdl_candidate','-Pghdl_reference','reach_tb',"-gTESTCASE=$taskCase","-gMODE=$taskMode","-gFOLLOW=$Follow","-gGAP=$Gap",'--assert-level=error','--ieee-asserts=disable'))}}
}
