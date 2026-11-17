onerror {quit -code 1}
onbreak {quit -code 1}
vlib work
vlog -sv -quiet savestates_sim.sv controller_tb.sv
vsim -c -t 1ps work.controller_tb
run -all
quit -code 0
