$ErrorActionPreference='Stop'
& 'C:/Program Files/nodejs/node.exe' "$PSScriptRoot/static_checks.js"
if($LASTEXITCODE -ne 0){throw 'Static gate failed'}
& 'C:/Program Files/nodejs/node.exe' "$PSScriptRoot/results.js"
if($LASTEXITCODE -ne 0){throw 'Simulation gate failed; Quartus not started'}
& 'C:/Program Files/nodejs/node.exe' "$PSScriptRoot/prepare_build.js"
if($LASTEXITCODE -ne 0){throw 'Source preparation failed'}
$repoRoot=(Resolve-Path "$PSScriptRoot/../..").Path
if(-not(Test-Path 'Z:/')){& subst.exe Z: $repoRoot;if($LASTEXITCODE -ne 0){throw 'Short path failed'}}
$project='Z:/tests/savestate_evolution_pending_fix/candidate/SMS'
if(-not(Test-Path "$project.qpf")){throw 'Short path mapping mismatch'}
if((Get-FileHash "$project.sv").Hash -ne (Get-FileHash "$PSScriptRoot/candidate/SMS.sv").Hash){throw 'Short path source mismatch'}
Push-Location "$PSScriptRoot/candidate"
try{
 $ErrorActionPreference='Continue'
 & 'C:/intelFPGA_lite/17.0/quartus/bin64/quartus_sh.exe' --flow compile $project *> compile.log
 $code=$LASTEXITCODE;$ErrorActionPreference='Stop'
 if($code -ne 0){throw 'Full Quartus failed'}
}finally{Pop-Location}
Write-Output 'PASS full Quartus compilation'
