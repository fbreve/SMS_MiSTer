onerror {quit -code 1}
onbreak {quit -code 1}
vmap altera_mf C:/intelFPGA_lite/17.0/modelsim_ase/altera/vhdl/altera_mf
vcom -2008 -quiet dpram_vendor.vhd
vlog -sv -quiet ram_equivalence_tb.sv
vsim -c -t 1ps -L altera_mf work.ram_equivalence_tb
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
