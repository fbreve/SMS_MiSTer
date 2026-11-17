onerror {quit -code 1}
onbreak {resume}
vlib work
vcom -2008 -quiet ../../rtl/io.vhd ../../rtl/eeprom_93c46.vhd io_gap_tb.vhd eeprom_gap_tb.vhd
vlog -sv -quiet ../../rtl/sega_controller.sv md_gap_tb.sv
vsim -c -t 1ps work.io_gap_tb
run -all
quit -sim
vsim -c -t 1ps work.eeprom_gap_tb
run -all
quit -sim
vsim -c -t 1ps work.md_gap_tb
run -all
quit -code 0
