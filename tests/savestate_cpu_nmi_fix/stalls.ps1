$ErrorActionPreference='Stop'
$env:FIX_SOURCE='0';$env:FIX_PROGRAM='0';$env:FIX_EDGE='0';$env:FIX_WIDTH='1';$env:FIX_SECOND='9999999';$env:FIX_HELD='0';$env:FIX_SCHEDULE='0';$env:FIX_FORMAT='0'
& "$PSScriptRoot/sim.ps1" -Do stalled.do -Label stalled_capture
$env:FIX_SOURCE='1';$env:FIX_EDGE='-45';$env:FIX_WIDTH='0'
& "$PSScriptRoot/sim.ps1" -Do stalled.do -Label stalled_gg
