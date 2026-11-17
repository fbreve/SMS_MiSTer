onerror {quit -code 1}
onbreak {quit -code 1}
vsim -L fm_candidate_work -L original_work -t 1ps -voptargs=+acc fm_candidate_work.fm_tb -gPHASE=70 -gREF=0 -gFM_ONLY=1 -g/fm_tb/dut/TB_FAST=1
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
