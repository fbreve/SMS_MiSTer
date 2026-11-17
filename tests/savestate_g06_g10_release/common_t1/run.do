onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps -L altera_mf vdp_work.vdp_tb -gTURBO=$env(RELEASE_TURBO) -gSAVE_ONLY=$env(RELEASE_SAVE_ONLY) -gDIAGNOSTIC=$env(RELEASE_DIAGNOSTIC) -gREFERENCE=$env(VDP_REFERENCE) -gGG=$env(VDP_GG) -gPAL=$env(VDP_PAL) -gREQUEST_X=$env(VDP_REQUEST_X) -gSPRITE_X=$env(VDP_SPRITE_X) -gSPRITES=$env(VDP_SPRITES) -gREPLAYS=$env(VDP_REPLAYS) -gPROTO=$env(VDP_PROTO) -g/vdp_tb/vdp1/vdp_vram_inst/init_file=UNUSED
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
