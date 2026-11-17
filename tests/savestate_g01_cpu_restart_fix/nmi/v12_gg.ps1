Push-Location $PSScriptRoot
try{
@"
onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps fixed_work.fixed_tb -gSOURCE=1 -gPROGRAM=0 -gEDGE=-45 -gWIDTH=1 -gSECOND=9999999 -gHELD=0 -gSCHEDULE=0 -gFORMAT=12 -gREPLAYS=3
set NumericStdNoWarnings 1
run -all
quit -code 0
"@|Set-Content legacy_12_s1.sim.do
& 'C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe' -c -do legacy_12_s1.sim.do -l legacy_12_s1.transcript *> legacy_12_s1.log
$s=Get-Content -Raw legacy_12_s1.log
if($LASTEXITCODE -ne 0 -or $s -match '\*\* (Error|Fatal|Failure)' -or $s -notmatch 'PASS F16 fixed'){throw 'v12 GG compatibility failed'}
Write-Output 'PASS legacy_12_s1'
}finally{Pop-Location}
