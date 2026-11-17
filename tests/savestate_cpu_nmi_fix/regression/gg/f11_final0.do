onerror {quit -code 1}
onbreak {quit -code 1}
vlib f11_final0_work
vcom -work f11_final0_work -2008 -quiet ../../../../rtl/io.vhd
vlog -work f11_final0_work -sv -quiet savestates_sim.sv f11_integration0.sv
vsim -c -t 1ps f11_final0_work.gg_integration_tb
run -all
quit -code 0
