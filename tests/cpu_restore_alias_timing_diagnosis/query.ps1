$ErrorActionPreference='Stop'
$taskRoot=(Resolve-Path "$PSScriptRoot/../..").Path
if(-not(Test-Path Z:/)){& subst.exe Z: $taskRoot}
$mapping=@(& subst.exe)|Where-Object{$_ -match '^Z:\\:'}
if(($mapping -split ' => ',2)[1].TrimEnd('\') -ne $taskRoot.TrimEnd('\')){throw 'Unexpected Z mapping'}
foreach($spec in @(@('baseline','savestate_g08_fm/quartus_early'),@('candidate','cpu_restore_output_alias/quartus_candidate1'))){
 & C:/intelFPGA_lite/17.0/quartus/bin64/quartus_sta.exe -t Z:/tests/cpu_restore_alias_timing_diagnosis/query.tcl "Z:/tests/$($spec[1])/SMS" "Z:/tests/cpu_restore_alias_timing_diagnosis/$($spec[0])" *> "$PSScriptRoot/$($spec[0])_query.log"
 if($LASTEXITCODE){throw "Query failed $($spec[0])"}
}
