onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps work.cpu_matrix_tb -gVARIANT=$env(YS_MODE) -gPROGRAM=$env(YS_PROGRAM) -gINTCASE=$env(YS_INTCASE)
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
