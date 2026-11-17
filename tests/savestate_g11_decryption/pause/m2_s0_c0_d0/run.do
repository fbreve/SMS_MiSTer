onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps -L altera_mf pause_work.pause_tb -gMODE=2 -gPROGRAM=1 -gDUAL=0 -gBOOT=1200 -gN=12000 -gTAIL_DELAY=0 -gSAVED_PAUSED=0 -gCURRENT_PAUSED=0 -g/pause_tb/dut/TB_FAST=1
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
