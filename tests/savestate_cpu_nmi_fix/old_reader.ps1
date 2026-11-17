$ErrorActionPreference='Stop'
$env:F14_STALL='0'
& "$PSScriptRoot/sim.ps1" -Folder "$PSScriptRoot/old_reader" -Do format.do -Label old_evolution
& "$PSScriptRoot/sim.ps1" -Folder "$PSScriptRoot/old_reader" -Do compat.do -Label old_non_evolution
