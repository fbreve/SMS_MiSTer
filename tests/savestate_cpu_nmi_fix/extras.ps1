$ErrorActionPreference='Stop'
$env:FIX_SOURCE='0';$env:FIX_PROGRAM='0';$env:FIX_EDGE='-60';$env:FIX_WIDTH='5';$env:FIX_SECOND='-15';$env:FIX_HELD='0';$env:FIX_SCHEDULE='0';$env:FIX_FORMAT='0'
& "$PSScriptRoot/sim.ps1" -Do released.do -Label both_released
foreach($i in 124,125){$env:FIX_FORMAT="$i";$env:FIX_EDGE='0';$env:FIX_WIDTH='1';$env:FIX_SECOND='9999999';& "$PSScriptRoot/sim.ps1" -Do released.do -Label "bad_subtype$i"}
