onerror {quit -code 1}
onbreak {}
source ../oracle.tcl
vsim -onfinish stop -t 1ps candidate_work.combined_tb -gSHIFT=$env(COMBINED_SHIFT) -gFRAME_EVENTS=0 -gCALIBRATE=true -gTRACE_CSV=true
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
set n 0
while {1} {
 run -all
 if {[examine /combined_tb/completed]==1} {break}
 set point [scalar /combined_tb/checkpoint]
 incr n
 foreach {who prefix wrapper} {candidate c /combined_tb/u reference r /combined_tb/r} {
  set words {}
  for {set i 0} {$i<104} {incr i} {lappend words [scalar /combined_tb/${prefix}_observe_$i]}
  equal_words $words [state_words $wrapper] "combined independent observation $who point=$point"
 }
 if {$point==1} {
  set expected [state_words /combined_tb/r]
  set image {}
  for {set i 0} {$i<104} {incr i} {lappend image [scalar /combined_tb/image($i)]}
  equal_words $image $expected "combined capture versus independent Tcl internals"
 }
 if {$point==3} {equal_words [state_words /combined_tb/r] $expected "combined full reference restore"}
 if {$n>28} {error "checkpoint count overflow"}
}
if {$n!=28} {error "missing combined oracle checkpoints $n"}
echo "PASS COMBINED TCL ORACLE ALL 28 checkpoints, both 104-word libraries"
quit -code 0
