$ErrorActionPreference='Stop'
$taskRepoRoot=(Resolve-Path "$PSScriptRoot/../..").Path
if(-not(Test-Path Z:/)){& subst.exe Z: $taskRepoRoot;if($LASTEXITCODE){throw 'Short path mapping failed'}}
$taskMapping=@(& subst.exe)|Where-Object{$_ -match '^Z:\\:'}
if(-not $taskMapping -or ($taskMapping -split ' => ',2)[1].TrimEnd('\') -ne $taskRepoRoot.TrimEnd('\')){throw 'Z: maps another directory'}
Push-Location "$PSScriptRoot/quartus_early"
try {
 & 'C:/intelFPGA_lite/17.0/quartus/bin64/quartus_sta.exe' -t Z:/tests/cram_memory_inference/timing_paths.tcl Z:/tests/cram_memory_inference/quartus_early/SMS Z:/tests/cram_memory_inference/early_paths *> "$PSScriptRoot/path_analysis.log"
 if($LASTEXITCODE){throw 'Path analysis failed'}
} finally {Pop-Location}
