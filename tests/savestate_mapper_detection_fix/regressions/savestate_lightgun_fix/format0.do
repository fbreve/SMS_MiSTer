onerror {quit -code 1}
onbreak {quit -code 1}
vlib format0_work
vlog -work format0_work -sv -quiet savestates_sim.sv format_tb.sv
vsim -c -t 1ps -gSTALL=0 format0_work.format_tb
run -all
quit -code 0
