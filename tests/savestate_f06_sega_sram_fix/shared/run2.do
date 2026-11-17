onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps -gSTALL=2 work.shared_tb
run -all
quit -code 0
