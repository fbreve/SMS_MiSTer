onerror {quit -code 1}
onbreak {quit -code 1}
vlib startup_work
vlog -work startup_work -sv ../../rtl/opll_snapshot.sv savestates_sim.sv startup_tb.sv
vsim -L local_work -t 1ps startup_work.startup_tb
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
