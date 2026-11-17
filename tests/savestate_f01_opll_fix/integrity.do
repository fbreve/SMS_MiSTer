onerror {quit -code 1}
onbreak {quit -code 1}
vlib integrity_work
vlog -work integrity_work -sv ../../rtl/opll_snapshot.sv integrity_tb.sv
vsim -L local_work -t 1ps integrity_work.integrity_tb
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
