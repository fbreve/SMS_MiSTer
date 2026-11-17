onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps -L altera_mf pause_work.pause_tb -gREF=1 -g/pause_tb/dut/TB_FAST=1 -gN=24000 -gREPLAYS=3 -gPAT=3 -gROUTE=2 -gDUAL=2
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
