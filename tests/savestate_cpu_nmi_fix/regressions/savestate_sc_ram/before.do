onerror {quit -code 1}
onbreak {quit -code 1}
vlib before_work
vcom -work before_work -2008 -quiet ../../../../rtl/dpram.vhd ../../../../rtl/memory_bus.vhd
vlog -work before_work -sv -quiet before_savestates.sv before_tb.sv
if {![info exists env(SC_STALL)]} {set env(SC_STALL) 0}
vsim -c -t 1ps -L altera_mf -gSTALL=$env(SC_STALL) before_work.sc_integration
set StdArithNoWarnings 1
set NumericStdNoWarnings 1
run -all
quit -code 0
