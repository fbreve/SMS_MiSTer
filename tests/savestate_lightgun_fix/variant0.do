onerror {quit -code 1}
onbreak {quit -code 1}
vlib variant0_work
vcom -work variant0_work -2008 -quiet ../../rtl/video.vhd ../../rtl/io.vhd
vlog -work variant0_work -sv -quiet savestates_sim.sv gun_fixture.sv boundary_tb.sv
vsim -c -t 1ps -gSTALL=0 -gPORT=1 variant0_work.boundary_tb
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
