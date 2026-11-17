$ErrorActionPreference='Stop'
if(Get-Process quartus_map,quartus_fit,quartus_sta,quartus_asm -ErrorAction SilentlyContinue){throw 'Do not overlap physical builds/query'}
$taskRoot=(Resolve-Path "$PSScriptRoot/../..").Path
if(-not(Test-Path Z:/)){& subst.exe Z: $taskRoot}
$mapping=@(& subst.exe)|Where-Object{$_ -match '^Z:\\:'}
if(($mapping -split ' => ',2)[1].TrimEnd('\') -ne $taskRoot.TrimEnd('\')){throw 'Unexpected Z mapping'}
foreach($taskName in @('baseline2','candidate2')){
 if(-not(Test-Path "$PSScriptRoot/quartus_$taskName/output_files/SMS.sta.summary")){throw 'Missing completed build'}
 & C:/intelFPGA_lite/17.0/quartus/bin64/quartus_sta.exe -t Z:/tests/cpu_restore_alias_seed2_pair/query.tcl "Z:/tests/cpu_restore_alias_seed2_pair/quartus_$taskName/SMS" "Z:/tests/cpu_restore_alias_seed2_pair/$taskName" *> "$PSScriptRoot/$($taskName)_query.log"
 if($LASTEXITCODE){throw "Query failed $taskName"}
}
