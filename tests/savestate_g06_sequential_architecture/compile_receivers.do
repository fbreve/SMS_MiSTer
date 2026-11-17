onerror {quit -code 1}
onbreak {quit -code 1}
vlib receiver_work
vcom -work receiver_work -2008 candidate_A/rtl/sprite_state_pkg.vhd candidate_A/rtl/vdp_sprite_shifter.vhd candidate_A/rtl/vdp_sprites.vhd
vlog -work receiver_work -sv candidate_A/rtl/sprite_snapshot.sv
quit -code 0
