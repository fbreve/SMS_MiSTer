onerror {quit -code 1}
onbreak {quit -code 1}
vsim -t 1ps -voptargs=+acc work_native_v17.native_tb -gFMCASE=$env(FMCASE) -gHISTORY=$env(HISTORY) -gREF=$env(REF) -gSTALL=$env(STALL) -g/native_tb/dut/TB_FAST=1
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
when {/native_tb/ss_freeze == 1} {echo "FM_BOUNDARY phase=[examine -radix hexadecimal /native_tb/fm/pg/MEM/phase_array] envelope=[examine -radix hexadecimal /native_tb/fm/eg/u_envelope_memory/egdata_set] slot=[examine -radix unsigned /native_tb/fm/s0/ff_count]"; nowhen 1}
run -all
quit -code 0
