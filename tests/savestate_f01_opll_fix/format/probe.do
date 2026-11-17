onerror {quit -code 1}
onbreak {quit -code 1}
vlib probe_work
vlog -work probe_work -sv ../../../rtl/opll_snapshot.sv savestates_sim.sv probe_tb.sv
vsim -t 1ps probe_work.vdp_tb -g/vdp_tb/dut/TB_FAST=1
run -all
quit -code 0
