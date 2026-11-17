$ErrorActionPreference='Stop';$taskRepoRoot=(Resolve-Path "$PSScriptRoot/../..").Path
if(-not(Test-Path Z:/)){& subst.exe Z: $taskRepoRoot;if($LASTEXITCODE){throw 'Mapping failed'}}
$taskMapping=@(& subst.exe)|Where-Object{$_ -match '^Z:\\:'}
if(-not $taskMapping -or ($taskMapping -split ' => ',2)[1].TrimEnd('\') -ne $taskRepoRoot.TrimEnd('\')){throw 'Z: maps elsewhere'}
Push-Location $PSScriptRoot
try{
 & 'C:/intelFPGA_lite/17.0/quartus/bin64/quartus_sta.exe' -t Z:/tests/cpu_restore_output_alias/failure_paths.tcl Z:/tests/cpu_restore_output_alias/quartus_candidate1/SMS Z:/tests/cpu_restore_output_alias/failure_setup.txt Z:/tests/cpu_restore_output_alias/core_setup.txt *> failure_paths.log
 if($LASTEXITCODE){throw 'Read-only failure-path query failed'}
}finally{Pop-Location}
