onerror {quit -code 1}
onbreak {quit -code 1}
vlib protocol_work
vlog -work protocol_work -sv -quiet ../../../rtl/opll_snapshot.sv ../candidate_A/rtl/sprite_snapshot.sv golden.sv candidate.sv protocol_tb.sv
quit -code 0
