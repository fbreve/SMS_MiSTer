onerror {quit -code 1}
onbreak {quit -code 1}
vlib work
vcom -2008 -quiet ../../rtl/dpram.vhd mapper_sim.vhd ../../rtl/memory_bus.vhd
vlog -sv -suppress 2244 -quiet ../../rtl/opll_snapshot.sv savestates_sim.sv sram_tb.sv lifecycle_tb.sv
vsim -c -t 1ps -L altera_mf work.sram_tb
set StdArithNoWarnings 1
set NumericStdNoWarnings 1
run -all
quit -code 0
