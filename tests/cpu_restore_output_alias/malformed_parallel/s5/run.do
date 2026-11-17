onerror {quit -code 1}
onbreak {quit -code 1}
vsim -t 1ps test_work.vdp_tb -gSHARD=5 -gSHARDS=8 -g/vdp_tb/dut/TB_FAST=1
set NumericStdNoWarnings 1
run -all
quit -code 0
