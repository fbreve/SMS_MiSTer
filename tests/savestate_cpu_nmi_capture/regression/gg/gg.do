onerror {quit -code 1}
onbreak {resume}
vlib work
vcom -2008 -quiet ../../../../rtl/io.vhd gg_tb.vhd
vsim -c -t 1ps work.gg_tb -gexpect_fixed=$env(GG_FIXED)
run -all
quit -code 0
