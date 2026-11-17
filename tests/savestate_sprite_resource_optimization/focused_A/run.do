onerror {quit -code 1}
onbreak {quit -code 1}
vlib miter_work
vlog -work miter_work -sv -quiet golden.sv savestates_sim.sv miter.sv
vsim -c -t 1ps miter_work.vdp_tb
run -all
quit -code 0
