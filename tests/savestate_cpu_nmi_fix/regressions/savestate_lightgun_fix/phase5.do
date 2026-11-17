onerror {quit -code 1}
onbreak {quit -code 1}
vlib phase5_work
vcom -work phase5_work -2008 -quiet ../../../../rtl/video.vhd ../../../../rtl/io.vhd
vlog -work phase5_work -sv -quiet savestates_sim.sv gun_fixture.sv boundary_tb.sv
vsim -c -t 1ps -gSTALL=1 -gCAPTURE_X=8 phase5_work.boundary_tb
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
