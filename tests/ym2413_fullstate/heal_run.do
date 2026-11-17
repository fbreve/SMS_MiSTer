onerror {quit -code 1}
onbreak {}
source oracle.tcl
vsim -onfinish stop -t 1ps candidate_work.heal_tb -gSHIFT=$env(HEAL_SHIFT) -gFOLLOW=$env(HEAL_FOLLOW)
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
set n 0
while {1} {
 run -all
 if {[examine /heal_tb/completed]==1} {break}
 set point [scalar /heal_tb/checkpoint]
 set c [state_words /heal_tb/u]
 set r [state_words /heal_tb/r]
 if {$point==1} {
  equal_words $c $r "identical pre-save state"
  set saved $r
 } elseif {$point==2} {
  set poison [expr {[lindex $saved 102]^1}]
  force -deposit /heal_tb/u/fm/tm/mixout [format "14'h%04x" $poison]
 } elseif {$point==3} {
  for {set i 0} {$i<104} {incr i} {
   if {$i==102} {continue}
   if {[lindex $c $i]!=[lindex $saved $i] || [lindex $r $i]!=[lindex $saved $i]} {error "persistent restore mismatch word $i"}
  }
  if {[lindex $c 102]==[lindex $r 102]} {error "omitted restore did not leave stale mixout"}
  echo "PASS stale output confirmed; all103 other fields restored"
 } elseif {$point==4 || $point==5 || $point==6} {
  equal_words $c $r "post-convergence point=$point"
 } else {error "unexpected checkpoint $point"}
 incr n
}
if {$n!=18} {error "incomplete HEAL checkpoints $n"}
echo "PASS HEAL oracle ALL checkpoints=$n"
quit -code 0
