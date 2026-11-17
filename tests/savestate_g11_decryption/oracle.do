onerror {quit -code 1}
onbreak {quit -code 1}
vlib oracle_work
vlog -sv -work oracle_work ../../rtl/parts.v ../../rtl/SEGASYS1_PRGDEC.v oracle_tb.sv
vsim -c oracle_work.oracle_tb
run -all
quit -code 0
