onerror {quit -code 1}
onbreak {quit -code 1}
vlib hcounter_guard0_work
vcom -work hcounter_guard0_work -2008 -quiet ../../rtl/video.vhd ../../rtl/io.vhd
vlog -work hcounter_guard0_work -sv -quiet savestates_sim.sv gun_fixture.sv hcounter_guard_tb.sv
vsim -c -t 1ps -gSTALL=0 hcounter_guard0_work.hcounter_guard
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
