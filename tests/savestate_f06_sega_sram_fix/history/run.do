onerror {quit -code 1}
vlib work
vlog -sv -quiet ../../../rtl/opll_snapshot.sv savestates_sim.sv history_tb.sv
vsim -c -t 1ps work.history_tb
run -all
quit -code 0
