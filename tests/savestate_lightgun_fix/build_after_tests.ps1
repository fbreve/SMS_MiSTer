$ErrorActionPreference='Stop'
$root=(Resolve-Path "$PSScriptRoot/../..").Path
$node='C:/Program Files/nodejs/node.exe'
Set-Location $root
while($true){
 $ErrorActionPreference='Continue'
 & $node "$PSScriptRoot/results.js" --sim-only *> "$PSScriptRoot/simulation_check.log"
 $gateCode=$LASTEXITCODE
 $ErrorActionPreference='Stop'
 if($gateCode -eq 0){break}
 Start-Sleep -Seconds 45
}
Write-Output 'PASS complete final-RTL simulation gate; starting full Quartus build'
if(-not(Test-Path 'Z:/tests/savestate_lightgun_fix/candidate/SMS.qpf')){& subst.exe Z: $root}
Set-Location "$PSScriptRoot/candidate"
$ErrorActionPreference='Continue'
& 'C:/intelFPGA_lite/17.0/quartus/bin64/quartus_sh.exe' --flow compile Z:/tests/savestate_lightgun_fix/candidate/SMS *> compile.log
$buildCode=$LASTEXITCODE
$ErrorActionPreference='Stop'
if($buildCode -ne 0){throw 'Quartus full compile failed'}
Set-Location $root
& $node "$PSScriptRoot/results.js" *> "$PSScriptRoot/final_results.log"
if($LASTEXITCODE -ne 0){throw 'Final evidence/resource check failed'}
& $node "$PSScriptRoot/review.js"
if($LASTEXITCODE -ne 0){throw 'Report generation failed'}
Write-Output 'PASS final Quartus/evidence/report generation'
