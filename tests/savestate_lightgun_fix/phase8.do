onerror {quit -code 1}
onbreak {quit -code 1}
vlib phase8_work
vcom -work phase8_work -2008 -quiet ../../rtl/video.vhd ../../rtl/io.vhd
vlog -work phase8_work -sv -quiet savestates_sim.sv gun_fixture.sv boundary_tb.sv
vsim -c -t 1ps -gSTALL=0 -gCAPTURE_X=14 phase8_work.boundary_tb
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
