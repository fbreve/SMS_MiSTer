onerror {quit -code 1}
onbreak {quit -code 1}
vlib format2_work
vlog -work format2_work -sv -quiet savestates_sim.sv format_tb.sv
vsim -c -t 1ps -gSTALL=2 format2_work.format_tb
run -all
quit -code 0
