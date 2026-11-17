onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps fixed_work.fixed_tb -gSOURCE=1 -gPROGRAM=0 -gEDGE=-15 -gWIDTH=0 -gSECOND=9999999 -gHELD=1 -gSCHEDULE=0 -gFORMAT=0 -gREPLAYS=3
set NumericStdNoWarnings 1
run -all
quit -code 0
