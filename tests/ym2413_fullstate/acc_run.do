onerror {quit -code 1}
onbreak {}
source oracle.tcl
vsim -onfinish stop -t 1ps candidate_work.acc_tb -gSHIFT=$env(ACC_SHIFT) -gFRAME_EVENTS=$env(ACC_FRAMES)
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
proc signed14 {x} {expr {$x>=8192?$x-16384:$x}}
proc check_observer {wrapper signalname} {
 set observed {}
 for {set i 0} {$i<104} {incr i} {lappend observed [scalar "/acc_tb/${signalname}_observe_$i"]}
 equal_words $observed [state_words $wrapper] "continuous observer $signalname"
}
set n 0
while {1} {
 run -all
 if {[examine /acc_tb/completed]==1} {break}
 set point [scalar /acc_tb/checkpoint]
 check_observer /acc_tb/u c
 check_observer /acc_tb/r r
 set c [state_words /acc_tb/u];set r [state_words /acc_tb/r]
 if {$point==1} {
  equal_words $c $r "identical pre-SAVE state";set saved $r
 } elseif {$point==2} {
  set pass [scalar /acc_tb/pass_number];set shift [scalar /acc_tb/SHIFT]
  set original [expr {([lindex $saved 101]>>6)&0x3fff}]
  switch $pass {
   0 {set poison 8191;set kind positive_max}
   1 {set poison 8192;set kind negative_min}
   2 {set poison [expr {$original<8192?8192:8191}];set kind opposite_sign}
   3 {
    set values [list 0 16383 5461 10922 [expr {(0x2413+$shift*7919)&16383}] [expr {(-$original)&16383}]]
    set poison [lindex $values [expr {$shift%6}]];set kind diverse_[expr {$shift%6}]
   }
   default {error "unexpected pass"}
  }
  if {$poison==$original} {set poison [expr {$poison^1}];append kind _unequal_adjustment}
  if {$pass==2 && (($poison^$original)&8192)==0} {error "opposite-sign poison missing"}
  force -deposit /acc_tb/u/fm/tm/mix [format "14'h%04x" $poison]
  echo "POISON shift=$shift pass=$pass kind=$kind saved=$original injected=$poison signed_saved=[signed14 $original] signed_injected=[signed14 $poison]"
 } elseif {$point==3} {
  for {set i 0} {$i<104} {incr i} {
   if {$i==101} {
    if {([lindex $c $i]&0xfff0003f)!=([lindex $saved $i]&0xfff0003f)} {error "mute/maddr changed"}
   } elseif {[lindex $c $i]!=[lindex $saved $i]} {error "candidate restore mismatch word $i"}
   if {[lindex $r $i]!=[lindex $saved $i]} {error "full reference restore mismatch word $i"}
  }
  if {(([lindex $c 101]>>6)&16383)!=$poison} {error "accumulator restore was not omitted"}
  echo "PASS poisoned mix retained, mute/maddr and all other fields fully restored"
 } elseif {$point==4} {
  for {set i 0} {$i<104} {incr i} {if {$i!=102 && [lindex $c $i]!=[lindex $r $i]} {error "first reset persistent mismatch word $i"}}
  if {[lindex $c 102]==[lindex $r 102]} {error "expected first poisoned output absent"}
  echo "PASS accumulator reset; poisoned sample confined to mixout"
 } elseif {$point==5 || $point==6 || $point==7} {
  equal_words $c $r "all-state equality point=$point"
 } else {error "unexpected checkpoint $point"}
 incr n
}
if {$n!=28} {error "incomplete checkpoints $n"}
echo "PASS ACC oracle ALL checkpoints=$n"
quit -code 0
