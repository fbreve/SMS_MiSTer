onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps direct_work.direct_tb
run -all
quit -code 0
