onerror {quit -code 1}
onbreak {quit -code 1}
vlib pause_work
vcom -work pause_work -2008 -quiet ../../rtl/AudioMix.vhd ../../rtl/video.vhd ../../rtl/T80/T80_Reg.vhd ../../rtl/T80/T80_MCode.vhd ../../rtl/T80/T80_ALU.vhd T80_sim.vhd T80s_sim.vhd ../../rtl/dpram.vhd ../../rtl/vdp_cram.vhd ../../rtl/vdp_background.vhd ../../rtl/vdp_sprite_shifter.vhd ../../rtl/vdp_sprites.vhd ../../rtl/vdp_main.vhd ../../rtl/vdp.vhd
vlog -work pause_work -suppress 2388 -quiet ../../rtl/jt89/jt89_vol.v ../../rtl/jt89/jt89_tone.v ../../rtl/jt89/jt89_noise.v ../../rtl/jt89/jt89_mixer.v ../../rtl/jt89/jt89.v
vlog -work pause_work -sv -quiet savestates_sim.sv pause_fixture.sv audio_tb.sv
quit -code 0
