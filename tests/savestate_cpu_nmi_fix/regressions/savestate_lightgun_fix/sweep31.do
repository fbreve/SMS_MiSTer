onerror {quit -code 1}
onbreak {quit -code 1}
vlib sweep_case31_work
vcom -work sweep_case31_work -2008 -quiet ../../../../rtl/video.vhd ../../../../rtl/io.vhd
vlog -work sweep_case31_work -sv -quiet savestates_sim.sv gun_fixture.sv boundary_tb.sv
vsim -c -t 1ps -gSTALL=3 -gSWEEP=1 -gPAL=1 -gMODE=0 -gBORDER=1 -gPX=255 -gPY=255 sweep_case31_work.boundary_tb
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
