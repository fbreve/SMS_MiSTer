onerror {quit -code 1}
onbreak {quit -code 1}
vlib combined1_work
vcom -work combined1_work -2008 -quiet ../../../../rtl/io.vhd
vlog -work combined1_work -sv -quiet savestates_sim.sv paddle_fixture.sv routing_fixture.sv integration_tb.sv
if {![info exists env(PADDLE_CASE)]} {set env(PADDLE_CASE) -1}
vsim -c -t 1ps -gONLY=$env(PADDLE_CASE) -gSTALL=1 combined1_work.paddle_integration
run -all
quit -code 0
