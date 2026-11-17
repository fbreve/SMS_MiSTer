$ErrorActionPreference='Stop'
Set-Location $PSScriptRoot
$sim='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe'
if(Test-Path baseline_regression){throw 'Refuse overwriting baseline logs'}
New-Item -ItemType Directory baseline_regression | Out-Null
node verify_scope.js
if($LASTEXITCODE){throw 'Baseline identity failed'}
foreach($p in @('prepare_tests.js','prepare_nonfm.js','prepare_phases.js','prepare_patterns.js')){node $p;if($LASTEXITCODE){throw "Preparation failed: $p"}}
$env:MODE='0';$env:SHIFT='0';Remove-Item Env:FAST -ErrorAction SilentlyContinue
foreach($pair in @(@('compile.do','Errors: 0|do compile.do'),@('phase_compile.do','Errors: 0|do phase_compile.do'),@('map.do','PASS independent pattern ALL'),@('protocol.do','PASS protocol ALL'),@('nonfm.do','PASS nonFM ALL'),@('phases.do','PASS PHASE SWEEP ALL'),@('run.do','PASS fullstate'))){
 $name=[IO.Path]::GetFileNameWithoutExtension($pair[0]);$log="baseline_regression/$name"
 & $sim -c -wlf "$log.wlf" -do $pair[0] -l "$log.log" *> "$log.stdout.log"
 $code=$LASTEXITCODE;Set-Content "$log.exitcode" $code
 $s=Get-Content "$log.log" -Raw
 if($code -or $s -notmatch $pair[1] -or $s -match '\*\* (Fatal|Error|Failure):'){throw "Baseline regression failed: $name"}
 Write-Output "PASS baseline $name"
}
Write-Output 'PASS COMMITTED FULLSTATE BASELINE REGRESSIONS'
