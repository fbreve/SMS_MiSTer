onerror {quit -code 1}
onbreak {quit -code 1}
vlib work
vcom -2008 -work work ../../rtl/T80/T80_Reg.vhd ../../rtl/T80/T80_MCode.vhd ../../rtl/T80/T80_ALU.vhd T80_current_sim.vhd T80s_current_sim.vhd T80_ed_probe.vhd T80s_ed_probe.vhd
vlog -sv -work work cpu_tb.sv
vsim -c -t 1ps work.cpu_tb
run -all
quit -code 0
