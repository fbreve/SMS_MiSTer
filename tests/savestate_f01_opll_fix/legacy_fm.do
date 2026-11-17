onerror {quit -code 1}
onbreak {quit -code 1}
vlib legacy_fm_work
vlog -work legacy_fm_work -sv ../../rtl/opll_snapshot.sv legacy_fm_tb.sv
vsim -L local_work -t 1ps legacy_fm_work.legacy_fm_tb
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
