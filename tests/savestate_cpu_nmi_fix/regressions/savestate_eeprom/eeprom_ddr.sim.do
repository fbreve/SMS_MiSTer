onerror {quit -code 1}
onbreak {quit -code 1}
if {![info exists env(EEPROM_STALL)]} {set env(EEPROM_STALL) 0}
if {![info exists env(EEPROM_CASE)]} {set env(EEPROM_CASE) -1}
vsim -c -t 1ps -L altera_mf -gSTALL=$env(EEPROM_STALL) -gCASE_ONLY=$env(EEPROM_CASE) f11_final0_work.ee_integration
set StdArithNoWarnings 1
set NumericStdNoWarnings 1
run -all
quit -code 0
