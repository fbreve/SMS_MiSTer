onerror {quit -code 1}
onbreak {quit -code 1}
vlib integration_work1
vcom -work integration_work1 -2008 -quiet ../../../../rtl/io.vhd
vlog -work integration_work1 -sv -quiet savestates_sim.sv tap_fixture.sv integration_tb.sv ../../../../rtl/sega_controller.sv
if {![info exists env(TAP_STALL)]} {set env(TAP_STALL) 0}
if {![info exists env(TAP_CASE)]} {set env(TAP_CASE) -1}
vsim -c -t 1ps -gSTALL=$env(TAP_STALL) -gONLY=$env(TAP_CASE) integration_work1.tap_integration
run -all
quit -code 0
