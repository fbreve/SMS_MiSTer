$ErrorActionPreference='Stop'
if(Get-Process ghdl -ErrorAction SilentlyContinue){throw 'Wait for long campaign; no extra GHDL beyond four'}
& "$PSScriptRoot/run_ghdl.ps1" -Name compile_collision_probe -GhdlArgs @('-a','--std=08','-fsynopsys','-fexplicit','--work=candidate_work','--workdir=ghdl_candidate','-Pghdl_reference','feedback_collision_tb.vhd')
foreach($taskShift in 0..71){
 & "$PSScriptRoot/run_ghdl.ps1" -Name "collision_$taskShift" -GhdlArgs @('-r','--std=08','-fsynopsys','-fexplicit','--work=candidate_work','--workdir=ghdl_candidate','-Pghdl_reference','feedback_collision_tb',"-gSHIFT=$taskShift",'--assert-level=error','--ieee-asserts=disable')
}
Write-Output 'PASS collision-consumption probe phases=72 loads=144'
