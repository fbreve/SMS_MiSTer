onerror {quit -code 1}
onbreak {quit -code 1}
vlib format_work
vlog -work format_work -sv ../../../rtl/opll_snapshot.sv savestates_sim.sv format_tb.sv
vsim -t 1ps format_work.vdp_tb -g/vdp_tb/dut/TB_FAST=1
run -all
quit -code 0
