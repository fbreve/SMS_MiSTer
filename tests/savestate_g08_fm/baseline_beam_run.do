onerror {quit -code 1}
onbreak {quit -code 1}
if {![info exists env(TB_FAST)]} {set env(TB_FAST) 1}
vsim -L known_baseline_work -L original_work -t 1ps known_baseline_work.fm_tb -gFASTVIDEO=0 -gPHASE=$env(PHASE) -gRESET_SKEW=$env(RESET_SKEW) -gREF=$env(REF) -gFM_ONLY=$env(FM_ONLY) -gSTALL=$env(STALL) -gN=$env(N) -gREPLAYS=$env(REPLAYS) -gSTEREO=$env(STEREO) -gPROGRAM=$env(PROGRAM) -gRANDOMSEED=$env(RANDOMSEED) -gCONVERGE=$env(CONVERGE) -gHISTORY=$env(HISTORY) -g/fm_tb/dut/TB_FAST=$env(TB_FAST)
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
