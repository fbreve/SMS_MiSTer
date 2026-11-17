onerror {quit -code 1}
onbreak {quit -code 1}
vlib format_work
vcom -work format_work -2008 -quiet ../../rtl/mapper_detect.vhd mapper_ctrl_sim.vhd ../../rtl/memory_decode.vhd
vlog -work format_work -sv -quiet savestates_sim.sv machine.sv format_tb.sv
vsim -c -t 1ps -voptargs=+acc format_work.format_tb
set NumericStdNoWarnings 1
run -all
quit -code 0
