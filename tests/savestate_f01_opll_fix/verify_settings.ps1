$ErrorActionPreference='Stop'
$repoRoot=(Resolve-Path "$PSScriptRoot/../..").Path
if(-not(Test-Path Z:/)){& subst.exe Z: $repoRoot;if($LASTEXITCODE){throw 'Short path failed'}}
$line=@(& subst.exe)|Where-Object{$_ -match '^Z:\\:'}
if(-not $line -or ($line -split ' => ',2)[1].TrimEnd('\') -ne $repoRoot.TrimEnd('\')){throw 'Wrong Z mapping'}
foreach($variant in @('raw','expanded')){
 $folder=if($variant -eq 'raw'){'settings_raw'}else{'quartus_early'}
 $ErrorActionPreference='Continue'
 & 'C:/intelFPGA_lite/17.0/quartus/bin64/quartus_sh.exe' -t Z:/tests/savestate_f01_opll_fix/export_settings.tcl "Z:/tests/savestate_f01_opll_fix/$folder" "Z:/tests/savestate_f01_opll_fix/settings_$variant`_assignments.txt" *> "$PSScriptRoot/settings_$variant`_stdout.log"
 $result=$LASTEXITCODE;$ErrorActionPreference='Stop';if($result){throw "Settings $variant query failed"}
}
