onerror {quit -code 1}
onbreak {quit -code 1}
vlib f11_integration_work
vcom -work f11_integration_work -2008 -quiet ../../rtl/dpram.vhd ../../rtl/vdp_cram.vhd ../../rtl/vdp_background.vhd ../../rtl/vdp_sprite_shifter.vhd ../../rtl/vdp_sprites.vhd ../../rtl/vdp_main.vhd ../../rtl/vdp.vhd
vlog -work f11_integration_work -sv -quiet savestates_sim.sv integration_tb.sv
vsim -c -t 1ps -L altera_mf f11_integration_work.integration_tb -g/integration_tb/vdp1/vdp_vram_inst/init_file=UNUSED -g/integration_tb/vdp2/vdp_vram_inst/init_file=UNUSED
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
