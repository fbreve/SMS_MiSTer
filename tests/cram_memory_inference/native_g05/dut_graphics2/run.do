set pid_fd [open simulation.pid w]
puts $pid_fd [pid]
close $pid_fd
onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps -L altera_mf vdp_work.vdp_tb -gSLOTS=8 -gGG=0 -gPAL=0 -gREQUEST_Y=192 -gREQUEST_X=40 -gSPRITES=0 -gREPLAYS=3 -gPROTO=1 -gTURBO=1 -gFIX=1 -gEXT_REFERENCE=1 -gWARMUP=1 -gSAMPLES=42000 -gREFERENCE=0 -g/vdp_tb/dut/TB_FAST=1 -g/vdp_tb/vdp1/vdp_vram_inst/init_file=UNUSED
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
