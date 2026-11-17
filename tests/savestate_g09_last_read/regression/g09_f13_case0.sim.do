onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps -voptargs=+acc f13_work.history_tb -gCASE=$env(F13_CASE)
set NumericStdNoWarnings 1
run -all
quit -code 0

