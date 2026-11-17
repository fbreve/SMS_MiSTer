onerror {quit -code 1}
onbreak {quit -code 1}
vsim -L fm_work -L original_work -t 1ps -voptargs=+acc fm_work.fm_tb -gPHASE=$env(PHASE) -gRESET_SKEW=$env(RESET_SKEW) -gREF=$env(REF) -gFM_ONLY=$env(FM_ONLY) -gSTALL=$env(STALL) -g/fm_tb/dut/TB_FAST=1
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
