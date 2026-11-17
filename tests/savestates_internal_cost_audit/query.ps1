$ErrorActionPreference='Stop'
$taskRepoRoot=(Resolve-Path "$PSScriptRoot/../..").Path
if(-not(Test-Path Z:/)){& subst.exe Z: $taskRepoRoot;if($LASTEXITCODE){throw 'Mapping failed'}}
$taskMapping=@(& subst.exe)|Where-Object{$_ -match '^Z:\\:'}
if(-not $taskMapping -or ($taskMapping -split ' => ',2)[1].TrimEnd('\') -ne $taskRepoRoot.TrimEnd('\')){throw 'Z: maps elsewhere'}
Push-Location $PSScriptRoot
try {
 & 'C:/intelFPGA_lite/17.0/quartus/bin64/quartus_sta.exe' -t Z:/tests/savestates_internal_cost_audit/registers.tcl Z:/tests/savestate_g08_fm/quartus_early/SMS Z:/tests/savestates_internal_cost_audit/registers.tsv *> registers_query.log
 if($LASTEXITCODE){throw 'Read-only query failed'}
}finally{Pop-Location}
