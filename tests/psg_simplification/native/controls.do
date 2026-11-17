onerror {quit -code 1}
onbreak {quit -code 1}
vcom -2008 -quiet routing.vhd
vlog -sv -quiet restore_controls_tb.sv
vsim -c -t 1ps work.restore_controls_tb
run -all
quit -code 0
