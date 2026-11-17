onerror {quit -code 1}
onbreak {quit -code 1}
vlib boundary_fixed_work
vcom -work boundary_fixed_work -2008 -quiet ../../rtl/mapper_detect.vhd mapper_ctrl_sim.vhd ../../rtl/memory_decode.vhd
vlog -work boundary_fixed_work -sv -quiet savestates_sim.sv machine.sv boundary_fixed_tb.sv
vsim -c -t 1ps -voptargs=+acc boundary_fixed_work.boundary_fixed_tb
set NumericStdNoWarnings 1
run -all
quit -code 0
