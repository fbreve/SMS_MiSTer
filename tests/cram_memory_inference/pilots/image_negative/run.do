onerror {quit -code 1}
onbreak {quit -code 1}
vlib image_work
vlog -work image_work -sv ../../../../rtl/opll_snapshot.sv savestates_sim.sv image_tb.sv
vsim -t 1ps image_work.vdp_tb -g/vdp_tb/dut/TB_FAST=1
run -all
quit -code 0
