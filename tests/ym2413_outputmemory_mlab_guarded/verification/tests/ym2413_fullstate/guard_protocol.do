onerror {quit -code 1}
onbreak {quit -code 1}
vlog -sv -work test_work guard_protocol_tb.sv
vsim -t 1ps test_work.guard_protocol_tb
run -all
quit -code 0
