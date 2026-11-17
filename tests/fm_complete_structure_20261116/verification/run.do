onerror {quit -code 1}
if {![info exists env(SHIFT)]} {set env(SHIFT) 0}
if {![info exists env(MODE)]} {set env(MODE) 0}
# Existing fast-flush adapter is used only for the additional mode/phase matrix.
# The unshifted mode-0 run retains the production 900000-clock flush.
if {$env(MODE)!=0 || $env(SHIFT)!=0} {
 set env(FAST) 1
 if {![file exists fast_work]} {
  vlib fast_work
  vmap fast_work fast_work
  vlog -sv -quiet -work fast_work opll_snapshot.sv savestates_fast.sv tb.sv
 }
}
if {[info exists env(FAST)] && $env(FAST)==1} {
 vsim -t 1ps -L candidate_work -L reference_work fast_work.tb -gSHIFT=$env(SHIFT) -gMODE=$env(MODE) -gNCONT=5000
} else {
 vsim -t 1ps -L candidate_work -L reference_work test_work.tb -gSHIFT=$env(SHIFT) -gMODE=$env(MODE)
}
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
  for {set i 0} {$i<50} {incr i} {
   set x [scalar "/tb/memory([expr {$base+0x2998+$i}])"]
   lappend actual [expr {$x&0xffffffff}] [expr {($x>>32)&0xffffffff}]
  }
  equal_words $actual $expected "DDRAM capture versus live internals"
 } elseif {$point==3} {
  equal_words [state_words /tb/fm] $expected "restored internals versus original T"
 }
 if {$checkpoint_total==9} {break}
}
onbreak {quit -code 1}
run -all
quit -code 0
