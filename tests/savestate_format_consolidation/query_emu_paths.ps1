$ErrorActionPreference='Stop'
$repoRoot=(Resolve-Path "$PSScriptRoot/../..").Path
if(-not(Test-Path Z:/)){& subst.exe Z: $repoRoot;if($LASTEXITCODE){throw 'Short path mapping failed'}}
$line=@(& subst.exe)|Where-Object{$_ -match '^Z:\\:'}
if(-not $line -or ($line -split ' => ',2)[1].TrimEnd('\') -ne $repoRoot.TrimEnd('\')){throw 'Z: maps another directory'}
$task='Z:/tests/savestate_format_consolidation'
foreach($name in @('baseline','experiment')){
 $project=if($name -eq 'baseline'){'Z:/tests/savestate_f01_opll_fix/quartus_final/SMS'}else{"$task/quartus_experiment/SMS"}
 & 'C:/intelFPGA_lite/17.0/quartus/bin64/quartus_sta.exe' -t "$task/emu_paths.tcl" $project "$task/$($name)_emu_setup.rpt" *> "$PSScriptRoot/$($name)_emu_query.log"
 if($LASTEXITCODE){throw "Emulation path query failed $name"}
}
