$ErrorActionPreference='Stop'
$d="$PSScriptRoot/regression";$sim="$d/sim.ps1"
$env:F14_STALL='0';$env:F15_OFFSET='0'
& $sim -Folder $d -Do regression_cpu.do -Label cpu_restore
foreach($i in 0,6){$env:F13_CASE="$i";& $sim -Folder $d -Do f13_run.do -Label "f13_case$i"}
foreach($i in 0,2,3,4,12,30){$env:F14_CASE="$i";& $sim -Folder $d -Do run.do -Label "f14_case$i"}
foreach($i in 0,1,2,5,6,7,8,9){$env:F14_CASE="$i";& $sim -Folder $d -Do directed.do -Label "f15_case$i"}
& $sim -Folder $d -Do cpu.do -Label f15_cpu
$env:PAUSE_CASE='4';$env:PAUSE_KEEP='0';$env:PAUSE_FULL='0';$env:PAUSE_STALL='0';$env:PAUSE_OFFSET='0';$env:PAUSE_DELAY='6'
& $sim -Folder "$d/pause" -Do fixed_case4_stall0_full0_offset0_delay6.do -Label f12_paused
