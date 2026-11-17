vsim -c -t 1ps -L altera_mf pause_work.pause_tb -g/pause_tb/dut/TB_FAST=$env(PAUSE_FAST) -gCASE=$env(PAUSE_CASE) -gKEEP=$env(PAUSE_KEEP) -gFULL=$env(PAUSE_FULL) -gSTALL=$env(PAUSE_STALL) -gOFFSET=$env(PAUSE_OFFSET) -gDELAY=$env(PAUSE_DELAY)
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
