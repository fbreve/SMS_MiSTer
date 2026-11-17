onerror {quit -code 1}
onbreak {quit -code 1}
vlib variant3_work
vcom -work variant3_work -2008 -quiet ../../../../rtl/video.vhd ../../../../rtl/io.vhd
vlog -work variant3_work -sv -quiet savestates_sim.sv gun_fixture.sv boundary_tb.sv
vsim -c -t 1ps -gSTALL=0 -gPAL=1 -gPORT=1 -gREGION=1 -gBORDER=1 -gALLOW_EQUAL=1 variant3_work.boundary_tb
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
