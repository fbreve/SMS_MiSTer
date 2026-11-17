onerror {quit -code 1}
onbreak {quit -code 1}
vlib work2
vcom -work work2 -2008 -quiet ../../rtl/dpram.vhd ../../rtl/memory_bus.vhd
vlog -work work2 -sv -quiet savestates_sim.sv integration_tb.sv
if {![info exists env(SC_STALL)]} {set env(SC_STALL) 0}
vsim -c -t 1ps -L altera_mf -gSTALL=$env(SC_STALL) work2.sc_integration
set StdArithNoWarnings 1
set NumericStdNoWarnings 1
run -all
quit -code 0
