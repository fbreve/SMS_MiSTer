onerror {quit -code 1}
onbreak {quit -code 1}
vlib compat_work
vcom -work compat_work -2008 -quiet ../../rtl/mapper_detect.vhd f13_mapper_ctrl_sim.vhd ../../rtl/memory_decode.vhd
vlog -work compat_work -sv -quiet savestates_sim.sv f13_machine.sv compat_tb.sv
vsim -c -t 1ps -voptargs=+acc compat_work.compat_tb
set NumericStdNoWarnings 1
run -all
quit -code 0
