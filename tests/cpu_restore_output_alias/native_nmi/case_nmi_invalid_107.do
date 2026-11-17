onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps -voptargs=+acc final_work.fixed_tb -gREPLAYS=3 -gSECOND=9999999 -gWIDTH=1 -gPROGRAM=0 -gFORMAT=107 -gSCHEDULE=0 -gHELD=0 -gEDGE=0 -gSOURCE=0
set NumericStdNoWarnings 1
run -all
quit -code 0
