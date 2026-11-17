onerror {quit -code 1}
onbreak {quit -code 1}
vsim -t 1ps trace_work.fixed_tb -g/fixed_tb/dut/TB_FAST=1 -gPROGRAM=30 -gOFFSET=1000 -gPERIOD=15 -gSYS=0 -gCAPTURES=0 -gSIGNATURE=0 -gINTCASE=2
set NumericStdNoWarnings 1
run -all
quit -code 0
