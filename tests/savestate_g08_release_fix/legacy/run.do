onerror {quit -code 1}
onbreak {quit -code 1}
vlib legacy_work
vlog -work legacy_work -sv -quiet savestates_sim.sv legacy_tb.sv
vsim -c legacy_work.vdp_tb -g/vdp_tb/dut/TB_FAST=1
run -all
quit -code 0
