onerror {quit -code 1}
onbreak {quit -code 1}
vlib phase11_work
vcom -work phase11_work -2008 -quiet ../../../../rtl/video.vhd ../../../../rtl/io.vhd
vlog -work phase11_work -sv -quiet savestates_sim.sv gun_fixture.sv boundary_tb.sv
vsim -c -t 1ps -gSTALL=3 -gCAPTURE_X=17 phase11_work.boundary_tb
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
