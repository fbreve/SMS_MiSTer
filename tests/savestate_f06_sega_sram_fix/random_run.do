onerror {quit -code 1}
onbreak {quit -code 1}
vsim -L work_random -L original_work -t 1ps -voptargs=+acc work_random.random_tb -gRANDOMSEED=$env(RANDOMSEED) -gREF=$env(REF) -gSTALL=$env(STALL) -g/random_tb/dut/TB_FAST=1
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
