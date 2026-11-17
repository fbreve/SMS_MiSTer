onerror {quit -code 1}
vlib work
vlog -sv -quiet ../../../rtl/opll_snapshot.sv savestates_sim.sv shared_tb.sv
quit -code 0
