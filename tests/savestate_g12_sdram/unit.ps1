$ErrorActionPreference='Stop'
$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem'
Push-Location $PSScriptRoot
try {
$lines=@('onerror {quit -code 1}','onbreak {quit -code 1}','vlib unit_work','vlog -work unit_work -sv -suppress 2244 -quiet sdram.v pin_model.sv controller_tb.sv','quit -code 0')
[IO.File]::WriteAllLines("$PSScriptRoot/unit_compile.do",$lines)
& "$bin/vsim.exe" -c -do 'do unit_compile.do' -l unit_compile.log *> unit_compile_stdout.log
if($LASTEXITCODE){throw 'unit compile'}
foreach($period in 10,15){foreach($tac in 0,3,7){
$script=@('onerror {quit -code 1}','onbreak {quit -code 1}',"vsim -c unit_work.controller_tb -gPERIOD=$period -gTAC=$tac",'run -all','quit -code 0')
[IO.File]::WriteAllLines("$PSScriptRoot/unit_run.do",$script)
$log="unit_p$period`_t$tac.log"
& "$bin/vsim.exe" -c -do 'do unit_run.do' -l $log *> "$log`_stdout.log"
$text=Get-Content -Raw $log
if($LASTEXITCODE -or $text -notmatch 'PASS CONTROLLER' -or $text -match '\*\* (Error|Fatal|Failure)'){throw "unit $period/$tac"}
Write-Output "PASS controller $period/$tac"
}}
}finally{Pop-Location}
