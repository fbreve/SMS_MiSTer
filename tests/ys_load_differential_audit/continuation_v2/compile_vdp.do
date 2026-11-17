onerror {quit -code 1}
onbreak {quit -code 1}
vmap altera_mf C:/intelFPGA_lite/17.0/modelsim_ase/altera/vhdl/altera_mf
vcom -2008 -quiet dpram.vhd video.vhd vdp_cram.vhd vdp_background.vhd vdp_sprite_shifter.vhd vdp_sprites.vhd vdp_main.vhd vdp.vhd
vlog -sv -quiet cpu_vdp_tb.sv
quit -code 0
