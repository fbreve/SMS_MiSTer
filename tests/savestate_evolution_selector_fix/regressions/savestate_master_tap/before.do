onerror {quit -code 1}
onbreak {quit -code 1}
vlib before_work
vlog -work before_work -sv -quiet before_fixture.sv before_replay.sv
if {![info exists env(TAP_TIMEOUT)]} {set env(TAP_TIMEOUT) 8}
vsim -c -t 1ps -gT=$env(TAP_TIMEOUT) before_work.before_replay
run -all
quit -code 0
