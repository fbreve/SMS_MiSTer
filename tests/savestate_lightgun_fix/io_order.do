onerror {quit -code 1}
onbreak {quit -code 1}
vlib io_order_work
vcom -work io_order_work -2008 -quiet ../../rtl/video.vhd ../../rtl/io.vhd
vlog -work io_order_work -sv -quiet savestates_sim.sv gun_fixture.sv io_order_tb.sv
vsim -c -t 1ps -gSTALL=0 io_order_work.io_order_tb
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
