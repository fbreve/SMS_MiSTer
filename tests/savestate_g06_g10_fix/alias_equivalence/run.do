onerror {quit -code 1}
onbreak {quit -code 1}
vlib miter_work
vcom -work miter_work -2008 -quiet ../../../rtl/vdp_sprite_shifter.vhd new_sprites.vhd
vcom -work miter_work -2008 -quiet old_sprites.vhd
vlog -work miter_work -sv -quiet miter.sv
vsim -c -t 1ps miter_work.miter
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
