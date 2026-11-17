$ErrorActionPreference='Stop'
$root=(Resolve-Path "$PSScriptRoot/../..").Path
& 'C:/Program Files/nodejs/node.exe' "$PSScriptRoot/results.js" --sim-only
if($LASTEXITCODE -ne 0){throw 'Simulation gate failed; Quartus not started'}
& 'C:/Program Files/nodejs/node.exe' "$PSScriptRoot/prepare_build.js"
if($LASTEXITCODE -ne 0){throw 'Build preparation failed'}
if(-not(Test-Path 'Z:/')){& subst.exe Z: $root;if($LASTEXITCODE -ne 0){throw 'Short-path mapping failed'}}
$project='Z:/tests/savestate_evolution_selector_fix/candidate/SMS'
if(-not(Test-Path "$project.qpf")){throw 'Z: mapping mismatch'}
if((Get-FileHash "$project.sv").Hash -ne (Get-FileHash "$PSScriptRoot/candidate/SMS.sv").Hash){throw 'Z: source mismatch'}
Push-Location "$PSScriptRoot/candidate"
try{
 $ErrorActionPreference='Continue'
 & 'C:/intelFPGA_lite/17.0/quartus/bin64/quartus_sh.exe' --flow compile $project *> compile.log
 $code=$LASTEXITCODE;$ErrorActionPreference='Stop'
 if($code -ne 0){throw 'Full Quartus compilation failed'}
}finally{Pop-Location}
Write-Output 'PASS full Quartus compile'
