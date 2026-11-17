onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps f11_controller_work.controller_tb
run -all
quit -code 0
