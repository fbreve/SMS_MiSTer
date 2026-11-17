onerror {quit -code 1}
onbreak {quit -code 1}
vlib f11_final_work
vcom -work f11_final_work -2008 -quiet ../../rtl/io.vhd
vlog -work f11_final_work -sv -quiet savestates_sim.sv ../../rtl/sega_controller.sv integration_tb.sv
vsim -c -t 1ps f11_final_work.md_integration
run -all
quit -code 0
