onerror {quit -code 1}
onbreak {quit -code 1}
vlog -sv -quiet targeted_tb.sv
vsim -c -t 1ps work.targeted_tb
run -all
quit -code 0
