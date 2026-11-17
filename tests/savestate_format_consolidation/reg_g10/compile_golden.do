while {[file exists parallel.lock]} { after 1000 }
onerror {quit -code 1}
onbreak {quit -code 1}
vlib golden_work
vcom -work golden_work -2008 -quiet ../../../rtl/video.vhd ../../../rtl/T80/T80_Reg.vhd ../../../rtl/T80/T80_MCode.vhd ../../../rtl/T80/T80_ALU.vhd T80_sim.vhd T80s_sim.vhd ../../../rtl/dpram.vhd ../../../rtl/vdp_cram.vhd rtl/vdp_background.vhd rtl/vdp_sprite_shifter.vhd rtl/vdp_sprites.vhd rtl/vdp_main.vhd rtl/vdp.vhd
vlog -work golden_work -sv -quiet ../../../rtl/opll_snapshot.sv golden_controller.sv vdp_tb.sv
quit -code 0

