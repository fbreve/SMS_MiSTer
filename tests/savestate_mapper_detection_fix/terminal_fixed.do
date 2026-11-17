onerror {quit -code 1}
onbreak {quit -code 1}
vlib terminal_fixed_work
vcom -work terminal_fixed_work -2008 -quiet ../../rtl/mapper_detect.vhd mapper_ctrl_sim.vhd ../../rtl/memory_decode.vhd
vlog -work terminal_fixed_work -sv -quiet savestates_sim.sv machine.sv terminal_fixed_tb.sv
vsim -c -t 1ps -voptargs=+acc terminal_fixed_work.terminal_fixed_tb
set NumericStdNoWarnings 1
run -all
quit -code 0
