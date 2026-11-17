onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps quick_work.fixed_tb -gPROGRAM=$env(G09_PROGRAM) -gOFFSET=$env(G09_OFFSET) -gPERIOD=$env(G09_PERIOD) -gSYS=$env(G09_SYS) -gCAPTURES=$env(G09_CAPTURES) -gSIGNATURE=$env(G01_SIGNATURE)
set NumericStdNoWarnings 1
run -all
quit -code 0


