onerror {quit -code 1}
onbreak {quit -code 1}
vlib work
vcom -2008 -quiet T80_Reg.vhd T80_MCode.vhd T80_ALU.vhd T80_context.vhd T80s_context.vhd T80_historical.vhd T80s_historical.vhd
vlog -sv -quiet cpu_matrix_tb.sv
quit -code 0
