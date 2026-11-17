onerror {quit -code 1}
onbreak {quit -code 1}
vlib f10_work2
vcom -work f10_work2 -2008 -quiet ../../../../rtl/dpram.vhd ../../../../rtl/memory_bus.vhd
vlog -work f10_work2 -sv -quiet savestates_sim.sv integration_tb.sv
if {![info exists env(SC_STALL)]} {set env(SC_STALL) 0}
vsim -c -t 1ps -L altera_mf -gSTALL=$env(SC_STALL) f10_work2.sc_integration
set StdArithNoWarnings 1
set NumericStdNoWarnings 1
run -all
quit -code 0
