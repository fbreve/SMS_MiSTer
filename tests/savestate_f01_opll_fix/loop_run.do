onerror {quit -code 1}
onbreak {quit -code 1}
vsim -t 1ps -voptargs=+acc work_loop_v17.loop_tb -gFMCASE=$env(FMCASE) -gHISTORY=$env(HISTORY) -gREF=$env(REF) -gSTALL=$env(STALL) -g/loop_tb/dut/TB_FAST=1
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
when {/loop_tb/ss_freeze == 1} {echo "FM_BOUNDARY phase=[examine -radix hexadecimal /loop_tb/fm/pg/MEM/phase_array] envelope=[examine -radix hexadecimal /loop_tb/fm/eg/u_envelope_memory/egdata_set] slot=[examine -radix unsigned /loop_tb/fm/s0/ff_count]"; nowhen 1}
run -all
quit -code 0
