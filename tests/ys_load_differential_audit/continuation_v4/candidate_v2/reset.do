onerror {quit -code 1}
vsim -c -wlf $env(YS_OUT).wlf -t 1ps work.ys_reset_tb -gSEED_IMPORT=1 -gCANDIDATE=$env(YS_CANDIDATE) -gREFERENCE=$env(YS_REFERENCE) -gSHAM_SRAM=$env(YS_SHAM) -gMOTION_STEP=4 +ROM=$env(YS_ROM) +OUT=$env(YS_OUT) +SEED_SLOT=$env(YS_SLOT) +SEED_SRAM=$env(YS_SRAM)
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
