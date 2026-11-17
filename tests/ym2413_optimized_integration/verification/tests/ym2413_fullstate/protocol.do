onerror {quit -code 1}
onbreak {quit -code 1}
vlog -sv -quiet -work test_work protocol_tb.sv
vsim -t 1ps test_work.protocol_tb
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
