onerror {quit -code 1}
onbreak {quit -code 1}
vlib work
vlog -sv -quiet controller_baseline.sv controller_candidate.sv existing_tb.sv directed_tb.sv
vsim -c -t 1ps work.savestate_tb
run -all
quit -sim
vsim -c -t 1ps work.directed_tb
run -all
quit -code 0
