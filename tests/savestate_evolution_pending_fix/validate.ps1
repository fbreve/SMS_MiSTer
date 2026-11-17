param([string]$Group='pending')
$ErrorActionPreference='Stop'
$sim="$PSScriptRoot/sim.ps1"
$env:F14_STALL='0'
switch($Group){
 pending {foreach($i in 0,1,2,5,6,7,8,9){$env:F14_CASE="$i";& $sim directed.do "fixed_directed$i"}}
 cpu {foreach($i in -1,0,1,14,28,29,30,31,42,43,44,45,46,59,74,89,149,209){$env:F15_OFFSET="$i";& $sim cpu.do "fixed_cpu$i"}}
 turbo {$env:F15_OFFSET='0';& $sim turbo_cpu.do turbo_cpu}
 pairs {foreach($i in 3,4){$env:F14_CASE="$i";& $sim directed.do "fixed_pair$i"}}
 selector {foreach($i in 0..30){$env:F14_CASE="$i";& $sim run.do "f14_case$i"};$env:F14_STALL='1';foreach($i in 0,2,3,4,12){$env:F14_CASE="$i";& $sim run.do "f14_stress$i"}; & $sim regression_cpu.do f14_cpu; & $sim history.do evolution_history}
 format {foreach($i in 0,1){$env:F14_STALL="$i";& $sim format.do "format_stall$i"}; & $sim compat.do compat}
 f13 {foreach($i in 0,6){$env:F13_CASE="$i";& $sim f13_run.do "f13_case$i"};& $sim banking.do banking}
}
