onerror {quit -code 1}
onbreak {quit -code 1}
vsim -t 1ps trace_work.fixed_tb -gPROGRAM=28 -gOFFSET=840 -gPERIOD=15 -gSYS=0 -gCAPTURES=0 -gSIGNATURE=0 -gINTCASE=1
set NumericStdNoWarnings 1
run -all
quit -code 0
