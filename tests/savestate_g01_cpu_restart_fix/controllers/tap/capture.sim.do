onerror {quit -code 1}
onbreak {quit -code 1}
if {![info exists env(TAP_STALL)]} {set env(TAP_STALL) 0}
if {![info exists env(TAP_CASE)]} {set env(TAP_CASE) -1}
vsim -c -t 1ps -gSTALL=$env(TAP_STALL) -gONLY=$env(TAP_CASE) f11_final0_work.tap_integration
run -all
quit -code 0
