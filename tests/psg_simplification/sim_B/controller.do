onerror {quit -code 1}
onbreak {quit -code 1}
vcom -2008 -quiet controls.vhd AudioMix.vhd
vlog -sv -quiet controller.sv controller_tb.sv
vsim -c -t 1ps -voptargs=+acc work.controller_tb
force -deposit /controller_tb/mix/toggle 0 0
run -all
quit -code 0
