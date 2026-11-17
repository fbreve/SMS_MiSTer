onerror {quit -code 1}
vlog -sv -quiet -work test_work map_tb.sv
vsim -t 1ps -L candidate_work test_work.map_tb
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
source oracle.tcl
for {set pass 0} {$pass<8} {incr pass} {
 run -all
 if {[scalar /map_tb/pass]!=$pass} {error "unexpected pattern checkpoint"}
 set expected {}
 for {set i 0} {$i<104} {incr i} {lappend expected [scalar "/map_tb/patterns([expr {$pass*104+$i}])"]}
 equal_words_mixer_exempt [state_words /map_tb/fm] $expected "independent injected pattern $pass"
}
onbreak {quit -code 1}
run -all
quit -code 0
