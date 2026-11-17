$ErrorActionPreference='Stop'
& 'C:/Program Files/nodejs/node.exe' "$PSScriptRoot/check_simulations.js"
if($LASTEXITCODE){throw 'Post-fix simulation gate failed'}
$repoRoot=(Resolve-Path "$PSScriptRoot/../..").Path
if(-not(Test-Path 'Z:/')){& subst.exe Z: $repoRoot;if($LASTEXITCODE){throw 'Short-path mapping failed'}}
if((Get-FileHash 'Z:/SMS.qpf').Hash -ne (Get-FileHash "$repoRoot/SMS.qpf").Hash){throw 'Short-path mapping is not this repository'}
# Separate source/database/output tree. The already running candidate compiler
# is intentional; no input/output path is shared between the two builds.
$project='Z:/tests/savestate_g06_g10_fix/quartus_baseline_date/SMS'
Push-Location "$PSScriptRoot/quartus_baseline_date"
try{
 $ErrorActionPreference='Continue'
 & 'C:/intelFPGA_lite/17.0/quartus/bin64/quartus_sh.exe' --flow compile $project *> compile.log
 $result=$LASTEXITCODE
 $ErrorActionPreference='Stop'
 if($result){throw "Baseline control full compilation failed ($result)"}
}finally{Pop-Location}
Write-Output 'PASS full unchanged baseline control compilation'
