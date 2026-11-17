onerror {quit -code 1}
vsim -c -t 1ps work.cpu_native_tb -gVARIANT=1 -gPROGRAM=11 -gINTCASE=5
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
