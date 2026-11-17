# Independent state packing from internal registers/RAM. Never reads ss_rdata.
# Kept explicit and separate from the RTL serializer and its validation masks.
proc scalar {path} {
 set raw [string trim [examine -radix hex $path] "{} "]
 if {![regexp {^[0-9a-fA-F]+$} $raw]} {error "unknown internal state $path: $raw"}
 return [expr 0x$raw]
}
proc record {path widths} {
 set raw [string map [list \{ "" \} ""] [examine -radix hex $path]]
 set parts [regexp -all -inline {\S+} $raw]
 if {[llength $parts]!=[llength $widths]} {error "record shape $path $parts"}
 set value 0
 foreach part $parts width $widths {
  if {![regexp {^[0-9a-fA-F]+$} $part]} {error "unknown record $path: $part"}
  set n [expr 0x$part]
  set value [expr {($value<<$width)|$n}]
 }
 return $value
}
proc state_words {wrapper} {
 set f "$wrapper/fm"
 set words [lrepeat 100 0]
 for {set i 0} {$i<9} {incr i} {
  set x [scalar "$f/ct/u_register_memory/regs_array($i)"]
  lset words $i [expr {(($x>>16)<<14)|($x&0x3fff)}]
 }
 for {set i 0} {$i<2} {incr i} {
  set x [scalar "$f/ct/vmem/voices($i)"]
  lset words [expr {9+2*$i}] [expr {$x&0xffffffff}]
  lset words [expr {10+2*$i}] [expr {$x>>32}]
 }
 for {set i 0} {$i<18} {incr i} {
  lset words [expr {13+$i}] [scalar "$f/pg/MEM/phase_array($i)"]
  lset words [expr {31+$i}] [scalar "$f/eg/u_envelope_memory/egdata_set($i)"]
  lset words [expr {58+$i}] [scalar "$f/og/Mmem/data_array($i)"]
 }
 for {set i 0} {$i<9} {incr i} {lset words [expr {49+$i}] [scalar "$f/og/Fmem/data_array($i)"]}
 lset words 76 [expr {[scalar "$wrapper/fm_a"]|([scalar "$wrapper/fm_d"]<<1)}]
 lset words 77 [expr {[scalar "$f/opllptr"]|([scalar "$f/oplldat"]<<8)|([scalar "$f/opllwr"]<<16)}]
 lset words 78 [scalar "$f/s0/ff_count"]
 foreach delay {2 5 8} {
  set count [scalar "$f/s$delay/ff_count"]
  if {$count!=(([lindex $words 78]&0x7f)+72-$delay)%72} {error "incoherent delayed slot counter $f/s$delay count=$count"}
 }
 lset words 79 [expr {[scalar "$f/og/fb_wr"]|([scalar "$f/og/mo_wr"]<<1)|([scalar "$f/og/fb_addr"]<<2)|([scalar "$f/og/mo_addr"]<<6)|([record "$f/og/fb_wdata" {1 9}]<<11)|([record "$f/og/mo_wdata" {1 9}]<<21)}]
 set cache 0
 for {set i 0} {$i<9} {incr i} {set cache [expr {$cache|([scalar "$f/ct/inst_cache($i)"]<<(4*$i))}]}
 lset words 80 [expr {$cache&0xffffffff}]
 lset words 81 [expr {($cache>>32)|([scalar "$f/ct/regs_addr"]<<4)|([scalar "$f/ct/slot_voice_addr"]<<8)|([scalar "$f/ct/user_voice_addr"]<<14)|([scalar "$f/ct/user_voice_wr"]<<15)}]
 set x [record "$f/ct/user_voice_wdata" {1 1 1 1 4 2 6 1 3 4 4 4 4}]
 lset words 82 [expr {$x&0xffffffff}]
 set r [scalar "$f/ct/regs_wdata"]
 lset words 83 [expr {($x>>32)|([scalar "$f/ct/regs_wr"]<<4)|(((($r>>16)<<14)|($r&0x3fff))<<5)}]
 set w [expr {[scalar "$f/ct/rflag"]&63}]
 foreach name {am pm wf ml tl fb ar dr} shift {6 7 8 9 13 20 23 27} {set w [expr {$w|([scalar "$f/ct/$name"]<<$shift)}]}
 lset words 84 $w
 set w 0
 foreach name {sl rr blk fnum rks key rhythm oracle_process/extra_mode oracle_process/vindex} shift {0 4 8 11 20 24 25 26 27} {set w [expr {$w|([scalar "$f/ct/$name"]<<$shift)}]}
 lset words 85 $w
 lset words 86 [expr {[scalar "$f/eg/rslot"]|([record "$f/eg/memin" {2 23}]<<5)|([scalar "$f/eg/memwr"]<<30)}]
 lset words 87 [expr {[scalar "$f/eg/egout"]|([scalar "$f/eg/oracle_process/lastkey"]<<13)}]
 lset words 88 [scalar "$f/eg/oracle_process/amphase"]
 lset words 89 [expr {[scalar "$f/eg/oracle_process/egphase"]|([scalar "$f/eg/oracle_process/egstate"]<<23)}]
 lset words 90 [scalar "$f/eg/oracle_process/ntable"]
 lset words 91 [expr {[scalar "$f/eg/u_attack_table/ff_w"]|([scalar "$f/eg/u_attack_table/ff_d1"]<<8)|([scalar "$f/eg/u_attack_table/ff_d2"]<<15)}]
 lset words 92 [scalar "$f/eg/u_attack_table/data"]
 lset words 93 [expr {[scalar "$f/pg/memwr"]|([scalar "$f/pg/memin"]<<1)|([scalar "$f/pg/pmcount"]<<19)}]
 lset words 94 [expr {[scalar "$f/pg/noise"]|([scalar "$f/pg/pgout"]<<1)}]
 lset words 95 [expr {[scalar "$f/pg/oracle_process/lastkey"]|([scalar "$f/pg/oracle_process/noise14"]<<18)|([scalar "$f/pg/oracle_process/noise17"]<<19)}]
 lset words 96 [expr {[scalar "$f/op/addr"]|([scalar "$f/op/ff_egout"]<<18)}]
 lset words 97 [expr {[scalar "$f/op/faddr"]|([scalar "$f/op/opout"]<<4)}]
 lset words 98 [expr {[scalar "$f/op/u_sine_table/ff_data0"]|([scalar "$f/op/u_sine_table/ff_data1"]<<11)|([scalar "$f/op/u_sine_table/ff_sign"]<<22)|([scalar "$f/op/u_sine_table/ff_wf"]<<23)}]
 lset words 99 [expr {[scalar "$f/op/u_sine_table/ff_weight"]|([scalar "$f/op/u_sine_table/ff_data"]<<9)}]
 return $words
}
proc equal_words {actual expected label} {
 for {set i 0} {$i<100} {incr i} {
  if {[lindex $actual $i]!=[lindex $expected $i]} {error [format "%s word %d actual=%08x expected=%08x" $label $i [lindex $actual $i] [lindex $expected $i]]}
 }
 echo "PASS independent internal oracle: $label words=100"
}
