onerror {quit -code 1}
onbreak {quit -code 1}
vlib boundary_work
vlog -work boundary_work -sv -quiet pause_fixture.sv boundary_tb.sv
vsim -c -t 1ps boundary_work.boundary_tb
run -all
quit -code 0
