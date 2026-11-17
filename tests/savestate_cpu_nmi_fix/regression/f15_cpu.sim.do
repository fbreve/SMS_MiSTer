onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps -voptargs=+acc pending_cpu_work.cpu_tb -gOFFSET=$env(F15_OFFSET)
set NumericStdNoWarnings 1
run -all
quit -code 0

