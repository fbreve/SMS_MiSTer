onerror {quit -code 1}
vlib strict_work
vlog -sv -quiet -work strict_work strict_tb.sv
vsim -t 1ps -L candidate_work -L reference_work strict_work.strict_tb
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
source oracle.tcl
for {set pass 0} {$pass<72} {incr pass} {
 run -all
 if {[scalar /strict_tb/checkpoint]!=1} {error "capture checkpoint"}
 set expected [state_words /strict_tb/r]
 equal_words [state_words /strict_tb/c] $expected "strict capture pass $pass"
 for {set i 0} {$i<100} {incr i} {if {[scalar "/strict_tb/image($i)"]!=[lindex $expected $i]} {error "capture versus independent oracle"}}
 run -all
 if {[scalar /strict_tb/checkpoint]!=2} {error "restore checkpoint"}
 equal_words [state_words /strict_tb/c] $expected "strict restored candidate pass $pass"
 equal_words [state_words /strict_tb/r] $expected "strict restored reference pass $pass"
 run -all
 if {[scalar /strict_tb/checkpoint]!=3} {error "continuation checkpoint"}
 equal_words [state_words /strict_tb/c] [state_words /strict_tb/r] "strict continuation pass $pass"
}
onbreak {quit -code 1}
run -all
quit -code 0
