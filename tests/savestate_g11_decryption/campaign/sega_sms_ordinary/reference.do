onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps -L altera_mf pause_work.pause_tb -gREF=1 -g/pause_tb/dut/TB_FAST=1 -g/pause_tb/MODE=2 -g/pause_tb/PROGRAM=1 -g/pause_tb/CONTEXT=0 -g/pause_tb/DUAL=3 -g/pause_tb/BOOT=1200 -g/pause_tb/N=24000 -g/pause_tb/REPLAYS=3 -g/pause_tb/TAIL_DELAY=0
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
