onerror {quit -code 1}
onbreak {quit -code 1}
vsim -t 1ps -L altera_mf pause_work.pause_tb -gDUAL=0 -gBOOT=1200 -gTAIL_DELAY=8 -gSAVED_PAUSED=0 -gCURRENT_PAUSED=0 -gTAC=1 -g/pause_tb/dut/TB_FAST=1
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
