onerror {quit -code 1}
onbreak {quit -code 1}
vlib final_work
vcom -work final_work -2008 -quiet ../../../rtl/video.vhd ../../../rtl/io.vhd ../../../rtl/T80/T80_Reg.vhd ../../../rtl/T80/T80_MCode.vhd ../../../rtl/T80/T80_ALU.vhd T80_integrated.vhd T80s_integrated.vhd
vlog -work final_work -sv -quiet savestates_integrated.sv machine.sv fixed_tb.sv
quit -code 0
