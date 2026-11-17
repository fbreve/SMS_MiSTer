onerror {quit -code 1}
onbreak {quit -code 1}
vlib before_work
vcom -work before_work -2008 -quiet baseline/rtl/eeprom_93c46.vhd baseline/rtl/cart_eeprom.vhd
vlog -work before_work -sv -quiet backing_before.sv
vsim -c -t 1ps before_work.backing_before
run -all
quit -code 0
