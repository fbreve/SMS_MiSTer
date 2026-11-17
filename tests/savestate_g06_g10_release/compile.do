onerror {quit -code 1}
onbreak {quit -code 1}
vlib vdp_work
vcom -work vdp_work -2008 -quiet ../../rtl/video.vhd ../../rtl/T80/T80_Reg.vhd ../../rtl/T80/T80_MCode.vhd ../../rtl/T80/T80_ALU.vhd T80_sim.vhd T80s_sim.vhd ../../rtl/dpram.vhd ../../rtl/vdp_cram.vhd ../../rtl/vdp_background.vhd shifter_proto.vhd sprites_proto.vhd main_proto.vhd vdp_proto.vhd
vlog -work vdp_work -sv -quiet savestates_sim.sv vdp_tb.sv
quit -code 0
