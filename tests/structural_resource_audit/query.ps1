$ErrorActionPreference='Stop'
$taskRepoRoot=(Resolve-Path "$PSScriptRoot/../..").Path
if(-not(Test-Path Z:/)){& subst.exe Z: $taskRepoRoot;if($LASTEXITCODE){throw 'Short path mapping failed'}}
$taskMapping=@(& subst.exe)|Where-Object{$_ -match '^Z:\\:'}
if(-not $taskMapping -or ($taskMapping -split ' => ',2)[1].TrimEnd('\') -ne $taskRepoRoot.TrimEnd('\')){throw 'Z: maps another directory'}
Push-Location "$taskRepoRoot/tests/savestate_g08_fm/quartus_early"
try {
 & 'C:/intelFPGA_lite/17.0/quartus/bin64/quartus_sta.exe' -t Z:/tests/structural_resource_audit/control_paths.tcl Z:/tests/savestate_g08_fm/quartus_early/SMS Z:/tests/structural_resource_audit *> "$PSScriptRoot/control_paths.log"
 if($LASTEXITCODE){throw 'Read-only control timing query failed'}
} finally {Pop-Location}
