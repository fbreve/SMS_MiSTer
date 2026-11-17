$ErrorActionPreference='Stop'
$d=$PSScriptRoot
$env:FIX_SOURCE='0';$env:FIX_PROGRAM='0';$env:FIX_EDGE='0';$env:FIX_WIDTH='1';$env:FIX_SECOND='9999999';$env:FIX_HELD='0';$env:FIX_SCHEDULE='0';$env:FIX_FORMAT='0'
& "$d/sim.ps1" -Do fixed.do -Label validation_pilot
for($i=0;$i -lt 8;$i++){
 Start-Process powershell -WindowStyle Hidden -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File',"$d/batch.ps1",'-Worker',"$i",'-Workers','8' -RedirectStandardOutput "$d/final_batch$i.out" -RedirectStandardError "$d/final_batch$i.err"
}
