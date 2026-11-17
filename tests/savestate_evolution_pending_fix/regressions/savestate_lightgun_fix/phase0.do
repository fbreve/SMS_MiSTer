onerror {quit -code 1}
onbreak {quit -code 1}
vlib phase0_work
vcom -work phase0_work -2008 -quiet ../../../../rtl/video.vhd ../../../../rtl/io.vhd
vlog -work phase0_work -sv -quiet savestates_sim.sv gun_fixture.sv boundary_tb.sv
vsim -c -t 1ps -gSTALL=0 -gCAPTURE_X=1 phase0_work.boundary_tb
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
