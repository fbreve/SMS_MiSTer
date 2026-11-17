onerror {quit -code 1}
onbreak {quit -code 1}
vlog -sv -quiet -work test_work protocol_tb.sv
vsim -t 1ps test_work.protocol_tb
run -all
quit -code 0
