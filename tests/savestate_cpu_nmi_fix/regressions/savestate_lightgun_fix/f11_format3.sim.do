onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps -gSTALL=3 format3_work.format_tb
run -all
quit -code 0
