onerror {quit -code 1}
onbreak {quit -code 1}
vlib guard_validator_work
vlog -sv -quiet -work guard_validator_work ../../rtl/opll_snapshot.sv savestates_sim.sv validator_stream_tb.sv
vsim -t 1ps guard_validator_work.validator_stream_tb
run -all
quit -code 0
