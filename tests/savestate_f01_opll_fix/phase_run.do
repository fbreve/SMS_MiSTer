onerror {quit -code 1}
onbreak {quit -code 1}
vsim -t 1ps phase_work.phase_tb -gSHIFT=$env(SHIFT) -gSTALL=$env(STALL)
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
