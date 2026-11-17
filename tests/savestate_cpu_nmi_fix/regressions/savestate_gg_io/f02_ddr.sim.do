onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps f11_final0_work.gg_integration_tb
run -all
quit -code 0
