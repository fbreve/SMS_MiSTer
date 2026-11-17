onerror {quit -code 1}
onbreak {quit -code 1}
vlib memory_work
vlog -work memory_work -sv ../../rtl/opll_snapshot.sv memory_tb.sv
vsim -t 1ps memory_work.memory_tb
run -all
quit -code 0
