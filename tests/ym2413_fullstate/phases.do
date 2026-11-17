onerror {quit -code 1}
onbreak {}
for {set shift 0} {$shift<72} {incr shift} {
 vsim -onfinish stop -t 1ps candidate_work.phase_tb -gSHIFT=$shift -gSTALL=3 -gNCE=200 -gLOADS=3
 set NumericStdNoWarnings 1
 set StdArithNoWarnings 1
 run -all
 if {[examine /phase_tb/completed]!=1} {error "incomplete phase $shift"}
 quit -sim
}
echo "PASS PHASE SWEEP ALL 72 offsets SAVE and three LOAD continuations"
quit -code 0
