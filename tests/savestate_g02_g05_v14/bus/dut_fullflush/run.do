onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps -L altera_mf vdp_work.vdp_tb -gSLOTS=8 -gQUICK=1 -gTURBO=1 -gCLONE=1 -gSTALL=0 -gREFERENCE=0 -gWARMUP=1 -gEXT_REFERENCE=1 -gON_IO=2 -gREPLAYS=3 -g/vdp_tb/dut/TB_FAST=0 -g/vdp_tb/vdp1/vdp_vram_inst/init_file=UNUSED
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0

