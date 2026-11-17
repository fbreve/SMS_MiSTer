onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps -L altera_mf trace_work.fixed_tb -gPROGRAM=11 -gOFFSET=719 -gPERIOD=15 -gSYS=0 -gCAPTURES=0 -gSIGNATURE=0 -gINTCASE=0
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
