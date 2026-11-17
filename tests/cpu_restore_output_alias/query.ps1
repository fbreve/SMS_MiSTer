param([ValidateSet('candidate1','baseline2','candidate2')][string]$Name='candidate1')
$ErrorActionPreference='Stop';$taskRepoRoot=(Resolve-Path "$PSScriptRoot/../..").Path
if(-not(Test-Path Z:/)){& subst.exe Z: $taskRepoRoot;if($LASTEXITCODE){throw 'Mapping failed'}}
$taskMapping=@(& subst.exe)|Where-Object{$_ -match '^Z:\\:'}
if(-not $taskMapping -or ($taskMapping -split ' => ',2)[1].TrimEnd('\') -ne $taskRepoRoot.TrimEnd('\')){throw 'Z: maps elsewhere'}
Push-Location $PSScriptRoot
try{
 & 'C:/intelFPGA_lite/17.0/quartus/bin64/quartus_sta.exe' -t Z:/tests/cpu_restore_output_alias/registers.tcl "Z:/tests/cpu_restore_output_alias/quartus_$Name/SMS" "Z:/tests/cpu_restore_output_alias/registers_$Name.tsv" *> "registers_$Name.log"
 if($LASTEXITCODE){throw 'Read-only register query failed'}
}finally{Pop-Location}
