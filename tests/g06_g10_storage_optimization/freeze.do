onerror {quit -code 1}
onbreak {quit -code 1}
vlib freeze_work
vcom -work freeze_work -2008 -quiet ../../rtl/vdp_sprite_shifter.vhd ../../rtl/vdp_sprites.vhd
vlog -work freeze_work -sv freeze_tb.sv
vsim -voptargs=+acc freeze_work.freeze_tb
run -all
quit -code 0
