onerror {quit -code 1}
onbreak {quit -code 1}
vlib before_work
vcom -work before_work -2008 -quiet baseline/rtl/io.vhd
vlog -work before_work -sv -quiet baseline_savestates_sim.sv baseline/rtl/sega_controller.sv before_integration_tb.sv
vsim -c -t 1ps before_work.before_integration
run -all
quit -code 0
