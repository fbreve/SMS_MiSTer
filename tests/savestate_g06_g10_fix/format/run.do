onerror {quit -code 1}
onbreak {quit -code 1}
vlib format_work
vlog -work format_work -sv -quiet savestates_sim.sv format_tb.sv
vsim -c format_work.vdp_tb -g/vdp_tb/dut/TB_FAST=1
run -all
quit -code 0
