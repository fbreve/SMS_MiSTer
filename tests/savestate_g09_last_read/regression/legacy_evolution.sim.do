onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps -voptargs=+acc legacy_cpu_work.legacy_cpu_tb -gOFFSET=$env(F15_OFFSET)
set NumericStdNoWarnings 1
run -all
quit -code 0

