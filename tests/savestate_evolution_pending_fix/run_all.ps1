param([string]$Group='cpu')
$ErrorActionPreference='Stop'
$sim="$PSScriptRoot/sim.ps1"
switch($Group){
 cpu {foreach($i in 0,1,14,29,30,44,45,59,74,89,149,209){$env:F15_OFFSET="$i";& $sim cpu.do "cpu_offset$i"}}
 directed {$env:F14_STALL='0';foreach($i in 0,1,2,5,6,7,8,9,3,4){$env:F14_CASE="$i";& $sim directed.do "directed$i"}}
 regressions {
  $env:F14_STALL='0';foreach($i in 0..14){$env:F14_CASE="$i";& $sim run.do "reg_f14_$i"}
  & $sim regression_cpu.do reg_f14_cpu
  & $sim history.do reg_evolution_history
  foreach($i in 0,6){$env:F13_CASE="$i";& $sim f13_run.do "reg_f13_$i"}
  & $sim banking.do reg_banking
 }
}
