onerror {quit -code 1}
onbreak {quit -code 1}
vlib work
vcom -2008 -quiet ../../rtl/io.vhd
vlog -sv -quiet savestates_sim.sv integration_tb.sv
vsim -c -t 1ps work.gg_integration_tb
run -all
quit -code 0
