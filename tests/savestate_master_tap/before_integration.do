onerror {quit -code 1}
onbreak {quit -code 1}
vlib before_integration_work
vcom -work before_integration_work -2008 -quiet ../../rtl/io.vhd
vlog -work before_integration_work -sv -quiet before_savestates_sim.sv before_integration_fixture.sv before_integration_tb.sv ../../rtl/sega_controller.sv
if {![info exists env(TAP_STALL)]} {set env(TAP_STALL) 0}
if {![info exists env(TAP_CASE)]} {set env(TAP_CASE) -1}
vsim -c -t 1ps -gSTALL=$env(TAP_STALL) -gONLY=$env(TAP_CASE) before_integration_work.tap_integration
run -all
quit -code 0
