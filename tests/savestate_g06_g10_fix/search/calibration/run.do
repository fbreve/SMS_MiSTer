onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps -L altera_mf vdp_work.vdp_tb -gCALIBRATION=1 -gPAST_HISTORY=0 -gWARMUP=1 -gTURBO=1 -gREFERENCE=0 -gPROTO=1 -gEXT_REFERENCE=0 -g/vdp_tb/dut/TB_FAST=1 
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
