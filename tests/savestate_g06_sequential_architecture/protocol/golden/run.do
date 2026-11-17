onerror {quit -code 1}
onbreak {quit -code 1}
vsim -t 1ps protocol_work.protocol_tb -gBASELINE=1 -g/protocol_tb/impl/dut/TB_FAST=1
run -all
quit -code 0
