onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps -L altera_mf work.lifecycle_tb
set StdArithNoWarnings 1
set NumericStdNoWarnings 1
run -all
quit -code 0
