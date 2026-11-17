onerror {quit -code 1}
vlog -sv -quiet ys_environment_tb.sv
vsim -c -wlf environment.wlf -t 1ps work.ys_environment_tb -gSEED_IMPORT=1 -gCANDIDATE=0 +ROM=$env(YS_ROM) +OUT=environment +SEED_SLOT=$env(YS_SLOT) +SEED_SRAM=$env(YS_SRAM)
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
