$ErrorActionPreference='Stop'
$node='C:/Program Files/nodejs/node.exe'
& $node "$PSScriptRoot/check_simulations.js" --final
if($LASTEXITCODE -ne 0){throw 'Simulation gate failed; Quartus not started'}
$active=Get-Process quartus_sh,quartus_map,quartus_fit,quartus_sta -ErrorAction SilentlyContinue
if($active){throw 'An existing Quartus compiler is active; isolated build not started'}
$repoRoot=(Resolve-Path "$PSScriptRoot/../..").Path
if(-not(Test-Path 'Z:/')){& subst.exe Z: $repoRoot;if($LASTEXITCODE -ne 0){throw 'Short-path mapping failed'}}
if((Get-FileHash 'Z:/SMS.qpf').Hash -ne (Get-FileHash "$repoRoot/SMS.qpf").Hash){throw 'Short-path mapping is not this repository'}
$project='Z:/tests/savestate_g01_cpu_restart_fix/candidate/SMS'
if(-not(Test-Path "$project.qpf")){throw 'Prepare the source-only isolated candidate first'}
Push-Location "$PSScriptRoot/candidate"
try{
 $ErrorActionPreference='Continue'
 & 'C:/intelFPGA_lite/17.0/quartus/bin64/quartus_sh.exe' --flow compile $project *> compile.log
 $result=$LASTEXITCODE
 $ErrorActionPreference='Stop'
 if($result -ne 0){throw "Full Quartus compilation failed ($result)"}
}finally{Pop-Location}
Write-Output 'PASS full controlled Quartus compilation'
