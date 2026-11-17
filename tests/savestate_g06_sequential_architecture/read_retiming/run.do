onerror {quit -code 1}
onbreak {quit -code 1}
vlib retime_work
vcom -work retime_work -2008 ../candidate_A/rtl/sprite_state_pkg.vhd ../candidate_A/rtl/vdp_sprite_shifter.vhd ../candidate_A/rtl/vdp_sprites.vhd vdp_sprite_shifter_reference.vhd vdp_sprites_reference.vhd
vlog -work retime_work -sv retime_tb.sv
vsim -t 1ps -voptargs=+acc retime_work.retime_tb
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
