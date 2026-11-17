onerror {quit -code 1}
onbreak {resume}
vlib before_work
vcom -work before_work -2008 -quiet baseline/rtl/eeprom_93c46.vhd protocol_before.vhd
vsim -c -t 1ps before_work.protocol_before
run -all
quit -code 0
