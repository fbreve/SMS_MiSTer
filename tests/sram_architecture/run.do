onerror {quit -code 1}
onbreak {quit -code 1}
vlib work
vcom -2008 -quiet ../../rtl/dpram.vhd mapper_ctrl_sim.vhd ../../rtl/memory_bus.vhd ../../rtl/io.vhd
vlog -sv -suppress 2244 -quiet characterization.sv
vsim -c -t 1ps -L altera_mf work.characterization
run -all
quit -code 0
