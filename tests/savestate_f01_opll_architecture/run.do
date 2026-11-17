onerror {quit -code 1}
onbreak {quit -code 1}
vsim -t 1ps -voptargs=+acc work_fast.pause_tb -gFMCASE=$env(FMCASE) -gHISTORY=$env(HISTORY) -gREF=$env(REF) -gSTALL=$env(STALL) -g/pause_tb/dut/TB_FAST=1
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
when {/pause_tb/ss_freeze == 1} {echo "FM_BOUNDARY phase=[examine -radix hexadecimal /pause_tb/fm/pg/MEM/phase_array] envelope=[examine -radix hexadecimal /pause_tb/fm/eg/u_envelope_memory/egdata_set] slot=[examine -radix unsigned /pause_tb/fm/s0/ff_count]"; nowhen 1}
run -all
quit -code 0
