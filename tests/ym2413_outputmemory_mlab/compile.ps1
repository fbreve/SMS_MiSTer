$ErrorActionPreference='Stop'
$taskNames=@('vm2413','slotcounter','voicerom','voicememory','registermemory','attacktable','envelopememory','envelopegenerator','phasememory','phasegenerator','sinetable','operator','feedbackmemory','outputmemory','lineartable','outputgenerator','temporalmixer','controller','opll')
foreach($taskLib in @('candidate','reference')){
 $taskPath=Join-Path $PSScriptRoot "worktree/tests/ym2413_fullstate/ghdl_$taskLib"
 if(!(Test-Path $taskPath)){New-Item -ItemType Directory $taskPath -ErrorAction Stop | Out-Null}
 foreach($taskName in $taskNames){& "$PSScriptRoot/run_ghdl.ps1" -Name "compile_${taskLib}_$taskName" -GhdlArgs @('-a','--std=08','-fsynopsys','-fexplicit',"--work=${taskLib}_work","--workdir=ghdl_$taskLib","$taskLib/$taskName.vhd")}
 & "$PSScriptRoot/run_ghdl.ps1" -Name "compile_${taskLib}_wrapper" -GhdlArgs @('-a','--std=08','-fsynopsys','-fexplicit',"--work=${taskLib}_work","--workdir=ghdl_$taskLib","${taskLib}_wrapper.vhd")
}
& "$PSScriptRoot/run_ghdl.ps1" -Name compile_output_tb -GhdlArgs @('-a','--std=08','-fsynopsys','-fexplicit','--work=candidate_work','--workdir=ghdl_candidate','-Pghdl_reference','output_tb.vhd')
Write-Output 'PASS independent native libraries compiled'
