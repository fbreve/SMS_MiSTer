onerror {quit -code 1}
onbreak {quit -code 1}
vlib format_work
vlog -work format_work -sv -quiet ../../../rtl/opll_snapshot.sv ../candidate_A/rtl/sprite_snapshot.sv golden.sv candidate.sv format_tb.sv
vsim -t 1ps format_work.protocol_tb -gBASELINE=0 -g/protocol_tb/impl/dut/TB_FAST=1
run -all
quit -code 0
