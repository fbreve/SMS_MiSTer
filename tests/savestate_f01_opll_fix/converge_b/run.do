onerror {quit -code 1}
onbreak {quit -code 1}
vsim -t 1ps -voptargs=+acc work_v17.pause_tb -gFMCASE=0 -gHISTORY=1 -gSTALL=0 -gSEED=0 -gCONVERGE=1 -gFM_SUPPRESS=0 -gTARGET=0 -gREF=$env(REF) -g/pause_tb/dut/TB_FAST=1
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
