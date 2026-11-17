onerror {quit -code 1}
onbreak {quit -code 1}
vlib sweep_case26_work
vcom -work sweep_case26_work -2008 -quiet ../../../../rtl/video.vhd ../../../../rtl/io.vhd
vlog -work sweep_case26_work -sv -quiet savestates_sim.sv gun_fixture.sv boundary_tb.sv
vsim -c -t 1ps -gSTALL=2 -gSWEEP=1 -gPAL=1 -gMODE=2 -gBORDER=0 -gPX=0 -gPY=128 sweep_case26_work.boundary_tb
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
