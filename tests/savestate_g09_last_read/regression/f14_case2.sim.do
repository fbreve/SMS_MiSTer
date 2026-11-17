if {![info exists env(F14_STALL)]} {set env(F14_STALL) 0}
onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps -voptargs=+acc fixed_work.evolution_fixed_tb -gCASE=$env(F14_CASE) -gSTALL=$env(F14_STALL)
set NumericStdNoWarnings 1
run -all
quit -code 0

