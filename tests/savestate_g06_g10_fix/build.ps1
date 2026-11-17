$ErrorActionPreference='Stop'
& 'C:/Program Files/nodejs/node.exe' "$PSScriptRoot/check_simulations.js"
if($LASTEXITCODE -ne 0){throw 'Simulation gate failed; Quartus not started'}
if(Get-Process quartus_sh,quartus_map,quartus_fit,quartus_sta -ErrorAction SilentlyContinue){throw 'An existing Quartus compilation is active'}
$repoRoot=(Resolve-Path "$PSScriptRoot/../..").Path
if(-not(Test-Path 'Z:/')){& subst.exe Z: $repoRoot;if($LASTEXITCODE -ne 0){throw 'Short-path mapping failed'}}
if((Get-FileHash 'Z:/SMS.qpf').Hash -ne (Get-FileHash "$repoRoot/SMS.qpf").Hash){throw 'Short-path mapping is not this repository'}
$project='Z:/tests/savestate_g06_g10_fix/quartus/SMS'
if(-not(Test-Path "$project.qpf")){throw 'Source-only build not prepared'}
Push-Location "$PSScriptRoot/quartus"
try{
 $ErrorActionPreference='Continue'
 & 'C:/intelFPGA_lite/17.0/quartus/bin64/quartus_sh.exe' --flow compile $project *> compile.log
 $result=$LASTEXITCODE
 $ErrorActionPreference='Stop'
 if($result -ne 0){throw "Full Quartus compilation failed ($result)"}
}finally{Pop-Location}
Write-Output 'PASS full controlled Quartus compilation'
