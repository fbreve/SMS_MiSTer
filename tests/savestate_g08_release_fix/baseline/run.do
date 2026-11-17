onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps -L altera_mf pause_work.pause_tb -gTARGET=$env(TARGET) -gSTALL=$env(STALL) -gREF=$env(REF) -gSEED=$env(SEED) -g/pause_tb/dut/TB_FAST=1
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
