onerror {quit -code 1}
onbreak {quit -code 1}
vcom -2008 -quiet -work test_work slot_exhaustive_tb.vhd
vsim -t 1ps test_work.slot_exhaustive_tb
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
