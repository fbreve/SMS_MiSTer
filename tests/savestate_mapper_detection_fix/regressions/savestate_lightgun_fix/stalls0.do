onerror {quit -code 1}
onbreak {quit -code 1}
vlib boundary0_work
vcom -work boundary0_work -2008 -quiet ../../../../rtl/video.vhd ../../../../rtl/io.vhd
vlog -work boundary0_work -sv -quiet savestates_sim.sv gun_fixture.sv boundary_tb.sv
vsim -c -t 1ps -gSTALL=0 boundary0_work.boundary_tb
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
