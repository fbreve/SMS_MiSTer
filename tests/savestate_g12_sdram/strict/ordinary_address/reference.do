onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps -L altera_mf pause_work.pause_tb -gREF=1 -g/pause_tb/dut/TB_FAST=1 -gDUAL=3 -gBOOT=1200 -gN=4000 -gREPLAYS=1 -gTRANSFER=1 -gWAIT_WINDOW=1 -gPATTERN=4
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
