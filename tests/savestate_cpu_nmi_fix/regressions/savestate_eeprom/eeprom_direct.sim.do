onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps work.replay
run -all
quit -code 0
