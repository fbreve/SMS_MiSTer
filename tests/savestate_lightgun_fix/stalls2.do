onerror {quit -code 1}
onbreak {quit -code 1}
vlib boundary2_work
vcom -work boundary2_work -2008 -quiet ../../rtl/video.vhd ../../rtl/io.vhd
vlog -work boundary2_work -sv -quiet savestates_sim.sv gun_fixture.sv boundary_tb.sv
vsim -c -t 1ps -gSTALL=2 boundary2_work.boundary_tb
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
