onerror {quit -code 1}
onbreak {quit -code 1}
vsim -t 1ps final_work.fixed_tb -g/fixed_tb/dut/TB_FAST=1 -gSOURCE=0 -gPROGRAM=0 -gEDGE=-300 -gWIDTH=0 -gSECOND=9999999 -gHELD=1 -gSCHEDULE=0 -gFORMAT=0 -gRELEASE_SECOND=0
set NumericStdNoWarnings 1
run -all
quit -code 0
