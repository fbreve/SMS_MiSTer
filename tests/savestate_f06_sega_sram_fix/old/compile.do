onerror {quit -code 1}
vlib work
vcom -2008 -quiet ../../../rtl/dpram.vhd mapper_sim.vhd ../../../rtl/memory_bus.vhd
vlog -sv -suppress 2244 -quiet ../../../rtl/opll_snapshot.sv savestates_sim.sv f06_tb.sv
quit -code 0
