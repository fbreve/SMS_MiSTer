onerror {quit -code 1}
onbreak {quit -code 1}
vlib combined0_work
vcom -work combined0_work -2008 -quiet ../../rtl/io.vhd
vlog -work combined0_work -sv -quiet savestates_sim.sv paddle_fixture.sv routing_fixture.sv integration_tb.sv
if {![info exists env(PADDLE_CASE)]} {set env(PADDLE_CASE) -1}
vsim -c -t 1ps -gONLY=$env(PADDLE_CASE) -gSTALL=0 combined0_work.paddle_integration
run -all
quit -code 0
