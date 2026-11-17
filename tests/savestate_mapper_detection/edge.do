onerror {quit -code 1}
onbreak {quit -code 1}
vlib edge_work
vcom -work edge_work -2008 -quiet ../../rtl/mapper_detect.vhd mapper_ctrl_sim.vhd ../../rtl/memory_decode.vhd
vlog -work edge_work -sv -quiet savestates_sim.sv machine.sv edge_tb.sv
vsim -c -t 1ps -voptargs=+acc edge_work.edge_tb -gMODE=$env(F13_EDGE_MODE)
set NumericStdNoWarnings 1
run -all
quit -code 0
