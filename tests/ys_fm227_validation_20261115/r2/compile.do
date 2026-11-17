onerror {quit -code 1}
onbreak {quit -code 1}
vlib work
vcom -2008 -quiet T80_Reg.vhd T80_MCode.vhd T80_ALU.vhd T80_context.vhd T80s_context.vhd dpram.vhd video.vhd vdp_cram.vhd vdp_background.vhd vdp_sprite_shifter.vhd vdp_sprites.vhd vdp_main.vhd vdp_probe.vhd mapper_ctrl.vhd io.vhd
vlog -sv -quiet opll_snapshot.sv baseline_controller.sv candidate_controller.sv controller_adapter.sv ys_environment_load_tb.sv
quit -code 0
