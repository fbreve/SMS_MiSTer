onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps -L altera_mf vdp_work.vdp_tb -gGG=1 -gPAL=0 -gREQUEST_X=40 -gSPRITE_X=120 -gSPRITES=8 -gREPLAYS=3 -gPROTO=1 -gTURBO=1 -gFIX=1 -gEXT_REFERENCE=1 -gWARMUP=1 -gPAUSE_CAPTURE=0 -gNATURAL_PHASE=0 -gSLOTS=8 -gOBSERVATIONS=1000 -gLEGACY=0 -gNEAR=0 -gTERMINATED=0 -gSP64=0 -gSPRITE_Y=167 -gFIRST_VISIBLE=0 -gREFERENCE=0 -g/vdp_tb/dut/TB_FAST=1 -g/vdp_tb/vdp1/vdp_vram_inst/init_file=UNUSED
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
