onerror {quit -code 1}
vsim -c -t 1ps -L altera_mf -gSTALL=2 work.ee_integration
set StdArithNoWarnings 1
set NumericStdNoWarnings 1
run -all
quit -code 0
