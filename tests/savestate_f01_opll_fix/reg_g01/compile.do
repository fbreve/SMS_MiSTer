onerror {quit -code 1}
onbreak {quit -code 1}
vlib trace_work
vcom -work trace_work -2008 -quiet ../../../rtl/video.vhd ../../../rtl/io.vhd ../../../rtl/T80/T80_Reg.vhd ../../../rtl/T80/T80_MCode.vhd ../../../rtl/T80/T80_ALU.vhd T80_integrated.vhd T80s_integrated.vhd mapper_ctrl_observed.vhd ../../../rtl/mapper_detect.vhd ../../../rtl/memory_decode.vhd
vlog -work trace_work -sv -quiet ../../../rtl/opll_snapshot.sv savestates_integrated.sv mapping.sv integrated_machine.sv trace_tb.sv
quit -code 0
