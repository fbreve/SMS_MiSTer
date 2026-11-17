$ErrorActionPreference='Stop'
$bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe'
foreach($omit in @(0,5,9)){
 foreach($shift in 0..71){
  $log="sweep_${omit}_${shift}.log"
  & $bin -c -do "onerror {quit -code 1}; onbreak {quit -code 1}; vsim -t 1ps search_work.search_tb -gOMIT=$omit -gSHIFT=$shift -gMODE=1; set NumericStdNoWarnings 1; set StdArithNoWarnings 1; run -all; quit -code 0" -l $log *> "sweep_${omit}_${shift}_stdout.log"
  if($LASTEXITCODE -or !(Select-String -Quiet -Path $log -Pattern 'PASS SEARCH')){throw "Search failed $omit $shift"}
 }
 Write-Output "Completed72-phase search omission$omit"
}
