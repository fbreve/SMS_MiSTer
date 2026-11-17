param([ValidateSet('v14','v15')][string]$Version='v15',[int]$ParallelControlPID=0)
$ErrorActionPreference='Stop'
& 'C:/Program Files/nodejs/node.exe' "$PSScriptRoot/check_simulations.js"
if($LASTEXITCODE -ne 0){throw 'Simulation gate failed; Quartus not started'}
if($ParallelControlPID){
 # Optional overlap only with our exact known control shell, in a disjoint
 # source/database/output tree. Do not silently join an unrelated build.
 $shells=@(Get-Process quartus_sh -ErrorAction SilentlyContinue)
 if($Version -ne 'v15' -or $shells.Count -ne 1 -or $shells[0].Id -ne $ParallelControlPID){throw 'Expected exactly the known v14 control shell'}
 $controlLog=Get-Content -Raw "$PSScriptRoot/quartus_v14/compile.log"
 if($controlLog -notmatch 'quartus_v14/SMS' -or $controlLog -match 'Full Compilation was successful'){throw 'Expected active isolated v14 control'}
}elseif(Get-Process quartus_sh,quartus_map,quartus_fit,quartus_sta -ErrorAction SilentlyContinue){throw 'An existing Quartus compilation is active'}
$repoRoot=(Resolve-Path "$PSScriptRoot/../..").Path
if(-not(Test-Path 'Z:/')){& subst.exe Z: $repoRoot;if($LASTEXITCODE -ne 0){throw 'Short-path mapping failed'}}
$aliasLine=@(& subst.exe) | Where-Object {$_ -match '^Z:\\:'}
if(-not $aliasLine -or ($aliasLine -split ' => ',2)[1].TrimEnd('\') -ne $repoRoot.TrimEnd('\')){throw 'Z: must resolve to this exact repository root'}
if((Get-FileHash 'Z:/SMS.qpf').Hash -ne (Get-FileHash "$repoRoot/SMS.qpf").Hash){throw 'Short-path mapping is not this repository'}
$project="Z:/tests/savestate_g05_background_fix/quartus_$Version/SMS"
if(-not(Test-Path "$project.qpf")){throw 'Source-only build not prepared'}
Push-Location "$PSScriptRoot/quartus_$Version"
try {
 $ErrorActionPreference='Continue'
 & 'C:/intelFPGA_lite/17.0/quartus/bin64/quartus_sh.exe' --flow compile $project *> compile.log
 $result=$LASTEXITCODE
 $ErrorActionPreference='Stop'
 if($result -ne 0){throw "Full Quartus compilation failed ($result)"}
}finally{Pop-Location}
Write-Output "PASS full controlled Quartus $Version compilation"
