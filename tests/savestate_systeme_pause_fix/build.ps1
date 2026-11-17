$ErrorActionPreference='Stop'
$root=(Resolve-Path "$PSScriptRoot/../..").Path
$node='C:/Program Files/nodejs/node.exe'
Set-Location $root
& $node "$PSScriptRoot/static_checks.js" *> "$PSScriptRoot/static.log"
if($LASTEXITCODE -ne 0){throw 'Static controller/scope check failed'}
while($true){
 $ErrorActionPreference='Continue'
 & $node "$PSScriptRoot/results.js" --sim-only *> "$PSScriptRoot/simulation_check.log"
 $code=$LASTEXITCODE;$ErrorActionPreference='Stop'
 if($code -eq 0){break}
 Start-Sleep -Seconds 45
}
Write-Output 'PASS complete F12 simulation gate; starting isolated full Quartus compilation'
& $node "$PSScriptRoot/prepare_build.js"
if($LASTEXITCODE -ne 0){throw 'Build preparation failed'}
if(-not(Test-Path 'Z:/')){& subst.exe Z: $root;if($LASTEXITCODE -ne 0){throw 'Could not create short build path'}}
$project='Z:/tests/savestate_systeme_pause_fix/candidate/SMS'
if(-not(Test-Path "$project.qpf")){throw 'Z: is mapped outside the expected workspace'}
if((Get-FileHash "$project.sv").Hash -ne (Get-FileHash "$PSScriptRoot/candidate/SMS.sv").Hash){throw 'Short-path project source mismatch'}
Set-Location "$PSScriptRoot/candidate"
$ErrorActionPreference='Continue'
& 'C:/intelFPGA_lite/17.0/quartus/bin64/quartus_sh.exe' --flow compile $project *> compile.log
$code=$LASTEXITCODE;$ErrorActionPreference='Stop'
if($code -ne 0){throw 'Quartus full compilation failed'}
Set-Location $root
& $node "$PSScriptRoot/resource_analysis.js" *> "$PSScriptRoot/resource_analysis.log"
if($LASTEXITCODE -ne 0){throw 'Physical resource analysis failed'}
& $node "$PSScriptRoot/results.js" *> "$PSScriptRoot/final_results.log"
if($LASTEXITCODE -ne 0){throw 'Final evidence/build-source check failed'}
& $node "$PSScriptRoot/review.js"
if($LASTEXITCODE -ne 0){throw 'Final report generation failed'}
Write-Output 'Full Quartus compilation and evidence/resource comparison completed'
