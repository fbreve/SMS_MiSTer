onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps trace_work.fixed_tb -gPROGRAM=29 -gOFFSET=0 -gPERIOD=15 -gSYS=0 -gCAPTURES=0 -gSIGNATURE=0 -gINTCASE=0
set NumericStdNoWarnings 1
run -all
quit -code 0
