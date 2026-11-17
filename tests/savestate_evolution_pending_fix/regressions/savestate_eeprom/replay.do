onerror {quit -code 1}
onbreak {quit -code 1}
vlib work
vcom -2008 -quiet ../../../../rtl/eeprom_93c46.vhd ../../../../rtl/cart_eeprom.vhd
vlog -sv -quiet replay.sv
vsim -c -t 1ps work.replay
run -all
quit -code 0
