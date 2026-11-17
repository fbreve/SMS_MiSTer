param([string]$Name='early')
$ErrorActionPreference='Stop'
$repoRoot=(Resolve-Path "$PSScriptRoot/../..").Path
if(-not(Test-Path Z:/)){& subst.exe Z: $repoRoot;if($LASTEXITCODE){throw 'Short path mapping failed'}}
$line=@(& subst.exe)|Where-Object{$_ -match '^Z:\\:'}
if(-not $line -or ($line -split ' => ',2)[1].TrimEnd('\') -ne $repoRoot.TrimEnd('\')){throw 'Z: maps another directory'}
Push-Location "$PSScriptRoot/quartus_$Name"
try{
 & 'C:/intelFPGA_lite/17.0/quartus/bin64/quartus_sta.exe' -t Z:/tests/savestate_g08_fm/emu_paths.tcl "Z:/tests/savestate_g08_fm/quartus_$Name/SMS" "Z:/tests/savestate_g08_fm/$($Name)_emu_setup.rpt" *> "$PSScriptRoot/$($Name)_emu_query.log"
 if($LASTEXITCODE){throw 'Path analysis failed'}
}finally{Pop-Location}

