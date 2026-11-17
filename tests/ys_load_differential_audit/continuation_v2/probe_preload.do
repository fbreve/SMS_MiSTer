onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps -L altera_mf work.cpu_vdp_tb -gVARIANT=$env(YS_MODE) -gPROGRAM=$env(YS_PROGRAM) -gINTCASE=0 -gPRELOAD=$env(YS_PRELOAD)
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
