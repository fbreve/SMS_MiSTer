onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps -voptargs=+acc trace_work.fixed_tb -gPROGRAM=4 -gOFFSET=800 -gPERIOD=10 -gSYS=0 -gCAPTURES=0 -gSIGNATURE=1 -gINTCASE=0
set NumericStdNoWarnings 1
run -all
quit -code 0
