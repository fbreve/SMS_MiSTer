onerror {quit -code 1}
onbreak {quit -code 1}
vlog -sv -quiet focused_tb.sv
vsim -c -t 1ps work.focused_tb
run -all
quit -code 0
