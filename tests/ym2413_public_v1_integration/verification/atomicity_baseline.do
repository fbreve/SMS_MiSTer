onerror {quit -code 1}
onbreak {quit -code 1}
vlib atomic_baseline
vlog -sv -quiet -work atomic_baseline baseline_opll_snapshot.sv baseline_savestates_sim.sv atomicity_baseline_tb.sv
vsim -t 1ps atomic_baseline.atomicity_tb
run -all
quit -code 0
