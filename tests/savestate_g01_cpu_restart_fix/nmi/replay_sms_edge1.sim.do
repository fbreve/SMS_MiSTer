onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps fixed_work.fixed_tb -gSOURCE=0 -gPROGRAM=0 -gEDGE=1 -gWIDTH=1 -gSECOND=9999999 -gHELD=0 -gSCHEDULE=0 -gFORMAT=0 -gREPLAYS=3
set NumericStdNoWarnings 1
run -all
quit -code 0
