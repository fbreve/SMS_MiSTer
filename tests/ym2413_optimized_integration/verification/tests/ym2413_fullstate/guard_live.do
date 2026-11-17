onerror {quit -code 1}
vlib guard_live_work
vlog -sv -work guard_live_work ../../rtl/opll_snapshot.sv savestates_fast.sv guard_live_tb.sv
onerror {quit -code 1}
if {![info exists env(SHIFT)]} {set env(SHIFT) 0}
if {![info exists env(MODE)]} {set env(MODE) 0}
vsim -t 1ps -L candidate_work -L reference_work guard_live_work.tb -gSHIFT=0 -gMODE=0 -gNCONT=5000
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
source oracle.tcl
set checkpoint_total 0
while {1} {
 run -all
 set point [scalar /tb/checkpoint]
 if {$point==0} {error "simulation ended without PASS completion"}
 incr checkpoint_total
 if {$point==1} {
  set expected [state_words /tb/fm]
  equal_words $expected [state_words /tb/reference_fm] "capture versus pinned reference"
  if {$checkpoint_total==1} {
   set mode [scalar /tb/MODE]
   for {set channel 0} {$channel<9} {incr channel} {
    set key [expr {([lindex $expected $channel]>>12)&1}]
    set wanted [expr {!($mode==4 && $channel==0)}]
    if {$key!=$wanted} {error "musical fixture key mismatch channel=$channel actual=$key expected=$wanted"}
   }
   if {$mode==3 && ([lindex $expected 84]&63)!=63} {error "rhythm stimulus not applied"}
   echo "PASS musical setup: all channel keys and rhythm state checked"
  }
 } elseif {$point==2} {
  set base [scalar /tb/base]
  set actual {}
  for {set i 0} {$i<52} {incr i} {
   set x [scalar "/tb/memory([expr {$base+0x2998+$i}])"]
   lappend actual [expr {$x&0xffffffff}] [expr {($x>>32)&0xffffffff}]
  }
  equal_words $actual $expected "DDRAM capture versus live internals"
 } elseif {$point==3} {
  equal_words_mixer_exempt [state_words /tb/fm] $expected "restored internals versus original T"
 }
 if {$point==4} {equal_words [state_words /tb/fm] [state_words /tb/reference_fm] "rejected LOAD left all104 live FM fields identical"}
 if {$checkpoint_total==11} {break}
}
onbreak {quit -code 1}
run -all
quit -code 0
