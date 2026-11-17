onerror {quit -code 1}
onbreak {quit -code 1}
vlib edge_work
vlog -work edge_work -sv -quiet pause_fixture.sv edge_tb.sv
vsim -c -t 1ps edge_work.edge_tb
run -all
quit -code 0
