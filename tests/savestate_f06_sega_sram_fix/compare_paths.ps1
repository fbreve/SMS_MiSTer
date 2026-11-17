param([string]$Name='early')
$ErrorActionPreference='Stop'
$taskRoot=(Resolve-Path "$PSScriptRoot/../..").Path
if(-not(Test-Path Z:/)){& subst.exe Z: $taskRoot;if($LASTEXITCODE){throw 'Short path mapping failed'}}
$taskMapping=@(& subst.exe)|Where-Object{$_ -match '^Z:\\:'}
if(-not $taskMapping -or ($taskMapping -split ' => ',2)[1].TrimEnd('\') -ne $taskRoot.TrimEnd('\')){throw 'Z: maps another directory'}
$task='Z:/tests/savestate_f06_sega_sram_fix'
foreach($taskName in @('baseline',$Name)){
 $taskProject=if($taskName -eq 'baseline'){'Z:/tests/savestate_f01_opll_fix/quartus_final/SMS'}else{"$task/quartus_$taskName/SMS"}
 $ErrorActionPreference='Continue'
 & 'C:/intelFPGA_lite/17.0/quartus/bin64/quartus_sta.exe' -t "$task/emu_paths.tcl" $taskProject "$task/$($taskName)_emu_setup.rpt" *> "$PSScriptRoot/$($taskName)_emu_query.log"
 $taskExit=$LASTEXITCODE;$ErrorActionPreference='Stop';if($taskExit){throw "Emulation path query failed $taskName"}
 if($taskName -eq 'baseline'){
  $ErrorActionPreference='Continue'
  & 'C:/intelFPGA_lite/17.0/quartus/bin64/quartus_sta.exe' -t "$task/timing_paths.tcl" $taskProject "$task/baseline_paths" *> "$PSScriptRoot/baseline_path_analysis.log"
  $taskExit=$LASTEXITCODE;$ErrorActionPreference='Stop';if($taskExit){throw 'Baseline path query failed'}
 }
}
