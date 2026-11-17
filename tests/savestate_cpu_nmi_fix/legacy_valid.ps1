$ErrorActionPreference='Stop'
$env:FIX_PROGRAM='0';$env:FIX_WIDTH='1';$env:FIX_SECOND='9999999';$env:FIX_HELD='0';$env:FIX_SCHEDULE='0'
foreach($v in 1,2){foreach($s in 0,1){
 $env:FIX_FORMAT="$v";$env:FIX_SOURCE="$s";$env:FIX_EDGE=if($s){'-45'}else{'0'}
 & "$PSScriptRoot/sim.ps1" -Do legacy_valid.do -Label "legacy${v}_source$s"
}}
