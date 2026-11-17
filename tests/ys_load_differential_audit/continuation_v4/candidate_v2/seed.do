onerror {quit -code 1}
vsim -c -t 1ps work.ys_map_tb -gCANDIDATE=0 -gSEED_EXPORT=1 -gREFERENCE=1 -gBOOT_FRAMES=150 +ROM=$env(YS_ROM) +OUT=seed
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
