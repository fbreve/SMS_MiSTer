onerror {quit -code 1}
onbreak {quit -code 1}
vlib transport_work
vlog -work transport_work -sv -quiet golden.sv savestates_sim.sv miter.sv
vsim -c -t 1ps transport_work.vdp_tb
run -all
quit -code 0
