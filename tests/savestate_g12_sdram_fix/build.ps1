param([ValidateSet('v16','candidate')][string]$Version='candidate',[int]$ParallelControlPID=0)
$ErrorActionPreference='Stop'
& 'C:/Program Files/nodejs/node.exe' "$PSScriptRoot/check_simulations.js"
if($LASTEXITCODE){throw 'Simulation gate failed; Quartus not started'}
if($ParallelControlPID){
 $shells=@(Get-Process quartus_sh -ErrorAction SilentlyContinue)
 if($Version -ne 'candidate' -or $shells.Count -ne 1 -or $shells[0].Id -ne $ParallelControlPID){throw 'Expected exact isolated v16 control shell'}
 $log=Get-Content -Raw "$PSScriptRoot/quartus_v16/compile.log"
 if($log -notmatch 'quartus_v16/SMS' -or $log -match 'Full Compilation was successful'){throw 'Control build is not active'}
}elseif(Get-Process quartus_sh,quartus_map,quartus_fit,quartus_sta -ErrorAction SilentlyContinue){throw 'Another Quartus build is active'}
$repoRoot=(Resolve-Path "$PSScriptRoot/../..").Path
if(-not(Test-Path 'Z:/')){& subst.exe Z: $repoRoot;if($LASTEXITCODE){throw 'Short-path mapping failed'}}
$line=@(& subst.exe)|Where-Object{$_ -match '^Z:\\:'}
if(-not $line -or ($line -split ' => ',2)[1].TrimEnd('\') -ne $repoRoot.TrimEnd('\')){throw 'Z: is not this repository'}
$project="Z:/tests/savestate_g12_sdram_fix/quartus_$Version/SMS"
Push-Location "$PSScriptRoot/quartus_$Version"
try {
 $ErrorActionPreference='Continue'
 & 'C:/intelFPGA_lite/17.0/quartus/bin64/quartus_sh.exe' --flow compile $project *> compile.log
 $result=$LASTEXITCODE
 $ErrorActionPreference='Stop'
 if($result){throw "Full Quartus failed ($result)"}
}finally{Pop-Location}
Write-Output "PASS full controlled Quartus $Version"
