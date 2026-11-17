param([Parameter(Mandatory=$true)][string]$Fixture,[Parameter(Mandatory=$true)][string]$Case,[Parameter(Mandatory=$true)][string]$Reference)
$ErrorActionPreference='Stop'
$caseRoot=Join-Path $PSScriptRoot "$Fixture/dut_$Case"
$referenceRoot=Join-Path $PSScriptRoot $Reference
$referenceLog=Get-Content -Raw -LiteralPath (Join-Path $referenceRoot simulation.log)
if($referenceLog -notmatch 'PASS UNINTERRUPTED REFERENCE' -or $referenceLog -notmatch '# End time:' -or $referenceLog -match '\*\* (Error|Fatal|Failure)'){throw 'Reference is not complete and passing'}
foreach($file in 'reference.dat','native_reference.dat','reference_events.dat','reference_memory.hex','reference_cram.hex'){if(Test-Path -LiteralPath (Join-Path $referenceRoot $file)){Copy-Item -LiteralPath (Join-Path $referenceRoot $file) -Destination (Join-Path $caseRoot $file)}}
Push-Location $caseRoot
try {
$simBin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem'
& "$simBin/vmap.exe" -c|Out-Null
& "$simBin/vmap.exe" vdp_work ../vdp_work|Out-Null
& "$simBin/vsim.exe" -c -do 'do run.do' -l simulation.log *> stdout.log
$result=Get-Content -Raw simulation.log
if($result -match '\*\* (Error|Fatal|Failure)|Errors: [1-9]' -or $result -notmatch 'PASS (RICH )?V1[45] VDP'){Get-Content simulation.log -Tail 18;throw "Failed $Fixture/dut_$Case"}
Write-Output "PASS $Fixture/dut_$Case"
} finally { Pop-Location }

