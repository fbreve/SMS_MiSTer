onerror {quit -code 1}
onbreak {resume}
vlib work
vcom -2008 -quiet ../../../../rtl/dpram.vhd ../../../../rtl/vdp_cram.vhd ../../../../rtl/vdp_background.vhd ../../../../rtl/vdp_sprite_shifter.vhd ../../../../rtl/vdp_sprites.vhd ../../../../rtl/vdp_main.vhd ../../../../rtl/vdp.vhd hcounter_tb.vhd
if {![info exists env(HCOUNTER_GG)]} {set env(HCOUNTER_GG) 0}
vsim -c -t 1ps -L altera_mf work.hcounter_tb -gexpect_fixed=$env(HCOUNTER_FIXED) -ggg_mode=$env(HCOUNTER_GG) -g/hcounter_tb/dut/vdp_vram_inst/init_file=UNUSED -g/hcounter_tb/reference/vdp_vram_inst/init_file=UNUSED
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
