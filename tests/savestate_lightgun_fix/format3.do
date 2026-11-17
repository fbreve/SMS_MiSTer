onerror {quit -code 1}
onbreak {quit -code 1}
vlib format3_work
vlog -work format3_work -sv -quiet savestates_sim.sv format_tb.sv
vsim -c -t 1ps -gSTALL=3 format3_work.format_tb
run -all
quit -code 0
