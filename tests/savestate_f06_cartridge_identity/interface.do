onerror {quit -code 1}
onbreak {quit -code 1}
vlib interface_work
vlog -sv -suppress 2244 -quiet -work interface_work fio_decoder.sv fio_tb.sv
vsim -c -t 1ps interface_work.interface_tb
run -all
quit -code 0
