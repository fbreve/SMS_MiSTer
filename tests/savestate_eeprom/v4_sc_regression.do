onerror {quit -code 1}
onbreak {quit -code 1}
vlib v4_work
vcom -work v4_work -2008 -quiet ../../rtl/dpram.vhd ../../rtl/eeprom_93c46.vhd ../../rtl/cart_eeprom.vhd
vlog -work v4_work -sv -quiet savestates_sim.sv integration_tb.sv
if {![info exists env(EEPROM_STALL)]} {set env(EEPROM_STALL) 0}
if {![info exists env(EEPROM_CASE)]} {set env(EEPROM_CASE) -1}
vsim -c -t 1ps -L altera_mf -gSTALL=$env(EEPROM_STALL) -gCASE_ONLY=$env(EEPROM_CASE) v4_work.ee_integration
set StdArithNoWarnings 1
set NumericStdNoWarnings 1
run -all
quit -code 0
