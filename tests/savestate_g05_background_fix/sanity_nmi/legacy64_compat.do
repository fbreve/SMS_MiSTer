onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps -L altera_mf final_work.fixed_tb -gRELEASE_SECOND=1 -gSECOND=-15 -gWIDTH=5 -gPROGRAM=0 -gFORMAT=99 -gSCHEDULE=0 -gHELD=0 -gEDGE=-60 -gSOURCE=0
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
