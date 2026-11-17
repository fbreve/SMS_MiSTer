onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps -voptargs=+acc cpu_work.cpu_tb
set NumericStdNoWarnings 1
run -all
quit -code 0

