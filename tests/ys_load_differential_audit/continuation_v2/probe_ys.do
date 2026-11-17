onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps -L altera_mf work.ys_cpu_vdp_tb -gVARIANT=$env(YS_MODE) +ROM=$env(YS_ROM)
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
