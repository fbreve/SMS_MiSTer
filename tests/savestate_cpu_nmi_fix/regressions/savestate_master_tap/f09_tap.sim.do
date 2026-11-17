onerror {quit -code 1}
onbreak {quit -code 1}
if {![info exists env(TAP_TIMEOUT)]} {set env(TAP_TIMEOUT) 8}
vsim -c -t 1ps -gT=$env(TAP_TIMEOUT) work.replay
run -all
quit -code 0
