onerror {quit -code 1}
vcom -2008 -quiet ../../rtl/mapper_detect.vhd
vlog -sv -quiet identity_tb.sv
vsim -c -t 1ps work.identity_tb
set NumericStdNoWarnings 1
run -all
quit -code 0
