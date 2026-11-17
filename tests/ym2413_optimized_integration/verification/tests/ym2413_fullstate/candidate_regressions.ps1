$ErrorActionPreference='Stop'
[System.Diagnostics.Process]::GetCurrentProcess().PriorityClass=[System.Diagnostics.ProcessPriorityClass]::Idle
Set-Location $PSScriptRoot
$sim='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe'
if(Test-Path candidate_regressions){throw 'Refuse overwriting candidate regressions'}
New-Item -ItemType Directory candidate_regressions | Out-Null
# These benches exercise the unchanged production controller/transport with mock FM.
# Baseline compiled SV sources are identical to current production; scope check
# independently rejects any controller/transport/integration change.
node verify_combined_scope.js
if($LASTEXITCODE){throw 'Unexpected candidate scope'}
foreach($pair in @(@('protocol.do','PASS protocol ALL'),@('nonfm.do','PASS nonFM ALL'))){
 $name=[IO.Path]::GetFileNameWithoutExtension($pair[0]);$log="candidate_regressions/$name"
 & $sim -c -wlf "$log.wlf" -do $pair[0] -l "$log.log" *> "$log.stdout.log"
 $code=$LASTEXITCODE;Set-Content "$log.exitcode" $code
 $s=Get-Content "$log.log" -Raw
 if($code -or $s -notmatch $pair[1] -or $s -match '\*\* (Fatal|Error|Failure):'){throw "Candidate regression failed: $name"}
 Write-Output "PASS candidate $name"
}
