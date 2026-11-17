onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps -L altera_mf fixed_case4_stall0_full0_offset0_delay6_work.pause_tb -gCASE=$env(PAUSE_CASE) -gKEEP=$env(PAUSE_KEEP) -gFULL=$env(PAUSE_FULL) -gSTALL=$env(PAUSE_STALL) -gOFFSET=$env(PAUSE_OFFSET) -gDELAY=$env(PAUSE_DELAY)
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
