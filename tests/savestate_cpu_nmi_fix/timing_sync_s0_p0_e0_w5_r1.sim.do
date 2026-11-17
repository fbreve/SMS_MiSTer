onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps -voptargs=+acc fixed_work.fixed_tb -gSOURCE=0 -gPROGRAM=0 -gEDGE=0 -gWIDTH=5 -gSECOND=9999999 -gHELD=0 -gSCHEDULE=0 -gFORMAT=0 -gREPLAYS=0
set NumericStdNoWarnings 1
run -all
quit -code 0
