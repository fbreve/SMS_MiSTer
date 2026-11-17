onerror {quit -code 1}
onbreak {quit -code 1}
vlib format1_work
vlog -work format1_work -sv -quiet savestates_sim.sv format_tb.sv
vsim -c -t 1ps -gSTALL=1 format1_work.format_tb
run -all
quit -code 0
