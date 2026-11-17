onerror {quit -code 1}
onbreak {quit -code 1}
vsim -L fm_causal_work -L original_work -t 1ps -voptargs=+acc fm_causal_work.fm_tb -gPHASE=70 -gREF=0 -gFM_ONLY=1 -g/fm_tb/dut/TB_FAST=1
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
when {/fm_tb/ss_freeze == 0 && /fm_tb/cache_ready == 1} {
 set lv [examine -radix binary /fm_tb/cache_l]
 set rv [examine -radix binary /fm_tb/cache_r]
 if {[examine -radix binary /fm_tb/audio_phase_in] == 0} {force -deposit /fm_tb/mix/audio_r 2#$rv} else {force -deposit /fm_tb/mix/audio_l 2#$lv}
 echo "CAUSAL_SINGLE_CACHE_DEPOSIT left=$lv right=$rv"
}
run -all
quit -code 0
