onerror {quit -code 1}
onbreak {quit -code 1}
vcom -2008 -quiet -work test_work opll_wrappers.vhd
vlog -sv -quiet -work test_work controller_baseline.sv controller_candidate.sv savestate_tb.sv
vsim -c -t 1ps -L test_work test_work.savestate_tb
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
