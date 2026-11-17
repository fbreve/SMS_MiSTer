onerror {quit -code 1}
onbreak {quit -code 1}
vlib phase2_work
vcom -work phase2_work -2008 -quiet ../../rtl/video.vhd ../../rtl/io.vhd
vlog -work phase2_work -sv -quiet savestates_sim.sv gun_fixture.sv boundary_tb.sv
vsim -c -t 1ps -gSTALL=2 -gCAPTURE_X=3 phase2_work.boundary_tb
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
