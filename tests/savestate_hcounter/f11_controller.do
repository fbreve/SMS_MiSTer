onerror {quit -code 1}
onbreak {quit -code 1}
vlib f11_controller_work
vlog -work f11_controller_work -sv -quiet savestates_sim.sv controller_tb.sv
vsim -c -t 1ps f11_controller_work.controller_tb
run -all
quit -code 0
