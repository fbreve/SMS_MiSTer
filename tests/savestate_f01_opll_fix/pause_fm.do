onerror {quit -code 1}
onbreak {quit -code 1}
vlib pause_fm_work
vlog -work pause_fm_work -sv ../../rtl/opll_snapshot.sv pause_fixture.sv pause_fm_tb.sv
vsim -L local_work -t 1ps pause_fm_work.pause_fm_tb
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
