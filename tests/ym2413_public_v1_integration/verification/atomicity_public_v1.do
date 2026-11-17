onerror {quit -code 1}
onbreak {quit -code 1}
vlib atomic_public_v1
vlog -sv -quiet -work atomic_public_v1 opll_snapshot.sv savestates_sim.sv atomicity_public_v1_tb.sv
vsim -t 1ps atomic_public_v1.atomicity_tb
run -all
quit -code 0
