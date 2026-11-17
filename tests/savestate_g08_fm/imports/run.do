onerror {quit -code 1}
onbreak {quit -code 1}
vlib imports_work
vlog -work imports_work -sv ../../../rtl/opll_snapshot.sv savestates_sim.sv imports_tb.sv
vsim -t 1ps imports_work.vdp_tb -g/vdp_tb/dut/TB_FAST=1
run -all
quit -code 0
