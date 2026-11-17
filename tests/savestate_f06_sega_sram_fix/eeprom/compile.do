onerror {quit -code 1}
vlib work
vcom -2008 -quiet ../../../rtl/dpram.vhd ../../../rtl/eeprom_93c46.vhd ../../../rtl/cart_eeprom.vhd
vlog -sv -quiet ../../../rtl/opll_snapshot.sv savestates_sim.sv integration_tb.sv replay.sv
quit -code 0
