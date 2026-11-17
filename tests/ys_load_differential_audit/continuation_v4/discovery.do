onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps work.ys_full_tb -gCANDIDATE=0 -gBOOT_FRAMES=240 -gACTION=-1 +ROM=$env(YS_ROM) +OUT=discovery
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0

