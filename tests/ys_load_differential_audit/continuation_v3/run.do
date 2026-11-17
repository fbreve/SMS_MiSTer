onerror {quit -code 1}
onbreak {quit -code 1}
if {![info exists env(YS_MOTION_STEP)]} {set env(YS_MOTION_STEP) 30}
vsim -c -t 1ps work.ys_full_tb -gCANDIDATE=$env(YS_CANDIDATE) -gBOOT_FRAMES=$env(YS_BOOT_FRAMES) -gACTION=$env(YS_ACTION) -gMOTION_STEP=$env(YS_MOTION_STEP) +ROM=$env(YS_ROM) +OUT=$env(YS_OUT)
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
