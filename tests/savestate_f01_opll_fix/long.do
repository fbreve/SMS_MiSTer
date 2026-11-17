onerror {quit -code 1}
onbreak {quit -code 1}
vcom -work local_work -2008 local_tb.vhd
vsim -t 1ps local_work.local_tb -gNCE=1050000 -gLOADS=1 -gSHIFT=10 -gSTALL=7
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
