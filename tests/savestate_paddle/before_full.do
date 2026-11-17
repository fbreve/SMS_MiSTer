onerror {quit -code 1}
onbreak {quit -code 1}
vlib before_full_work
vcom -work before_full_work -2008 -quiet ../../rtl/io.vhd
vlog -work before_full_work -sv -quiet before_savestates_sim.sv before_fixture.sv routing_fixture.sv before_full.sv
if {![info exists env(PADDLE_CASE)]} {set env(PADDLE_CASE) -1}
vsim -c -t 1ps -gONLY=$env(PADDLE_CASE) -gSTALL=0 before_full_work.before_full
run -all
quit -code 0
