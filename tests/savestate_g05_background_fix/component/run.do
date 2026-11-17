onerror {quit -code 1}
onbreak {quit -code 1}
vlib work
vcom -2008 -quiet vdp_background.vhd
vlog -sv -quiet miter.sv
vsim -t 1ps work.miter
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
