onerror {quit -code 1}
onbreak {quit -code 1}
vlib guard_early_work
vlog -sv -quiet -work guard_early_work ../../rtl/opll_snapshot.sv savestates_sim.sv early_validator_stream_tb.sv
vsim -t 1ps guard_early_work.early_validator_stream_tb
run -all
quit -code 0
