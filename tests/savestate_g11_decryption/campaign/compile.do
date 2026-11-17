onerror {quit -code 1}
onbreak {quit -code 1}
vlib pause_work
vcom -work pause_work -2008 -quiet ../../../rtl/spram.vhd ../../../rtl/AudioMix.vhd ../../../rtl/video.vhd ../../../rtl/T80/T80_Reg.vhd ../../../rtl/T80/T80_MCode.vhd ../../../rtl/T80/T80_ALU.vhd T80_sim.vhd T80s_sim.vhd ../../../rtl/dpram.vhd ../../../rtl/vdp_cram.vhd ../../../rtl/vdp_background.vhd ../../../rtl/vdp_sprite_shifter.vhd ../../../rtl/vdp_sprites.vhd ../../../rtl/vdp_main.vhd ../../../rtl/vdp.vhd
vlog -work pause_work -suppress 2388 -quiet ../../../rtl/jt89/jt89_vol.v ../../../rtl/jt89/jt89_tone.v ../../../rtl/jt89/jt89_noise.v ../../../rtl/jt89/jt89_mixer.v jt89.v
vcom -work pause_work -2008 -quiet ../../../rtl/memory_bus.vhd ../../../rtl/memory_decode.vhd mapper_ctrl_sim.vhd
vlog -work pause_work -sv -quiet ../../../rtl/parts.v ../../../rtl/MC8123.v ../../../rtl/SEGASYS1_PRGDEC.v decrypt_path.sv
vlog -work pause_work -sv -suppress 2244 -quiet sdram.v
vlog -work pause_work -sv -suppress 2388 -quiet pin_model.sv savestates_sim.sv pause_fixture.sv audio_tb.sv
quit -code 0
