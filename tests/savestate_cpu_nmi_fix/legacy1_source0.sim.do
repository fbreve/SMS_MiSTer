onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps -voptargs=+acc legacy_valid_work.legacy_valid_tb -gSOURCE=$env(FIX_SOURCE) -gPROGRAM=$env(FIX_PROGRAM) -gEDGE=$env(FIX_EDGE) -gWIDTH=$env(FIX_WIDTH) -gSECOND=$env(FIX_SECOND) -gHELD=$env(FIX_HELD) -gSCHEDULE=$env(FIX_SCHEDULE) -gFORMAT=$env(FIX_FORMAT)
set NumericStdNoWarnings 1
run -all
quit -code 0
