package require ::quartus::project
package require ::quartus::atoms
set dir [lindex $argv 0]
project_open $dir/candidate/SMS
read_atom_netlist -type cmp
set out [open [lindex $argv 1] w]
proc info_key {n k} {if {[catch {get_atom_node_info -key $k -node $n} v]} {return "?"} ; return $v}
proc nm {n} {return "[info_key $n NAME]"}
set seeds {}
foreach_in_collection n [get_atom_nodes] {
 set name [nm $n]
 if {[string match *savestates_inst|fm_saved_stage_zero* $name]} {lappend seeds $n}
}
puts $out "SEEDS [llength $seeds]"
proc dump {n tag} {
 global out
 puts $out "$tag NODE $n TYPE=[info_key $n TYPE] LOC=[info_key $n LOCATION] NAME=[nm $n]"
 foreach k {LUT_MASK LUT_MASK_PRIMARY LUT_MASK_SECONDARY ENUM_LUT_MASK STRING_LUT_MASK} {if {![catch {get_atom_node_info -key $k -node $n} v]} {puts $out "  $k=$v"}}
 foreach i [get_atom_iports -node $n] {
  set f [get_atom_port_info -key FANIN -node $n -port_id $i -type iport]
  set fn {}; if {[llength $f]>0} {set fn "[get_atom_node_info -key NAME -node [lindex $f 0]] ([get_atom_node_info -key TYPE -node [lindex $f 0]])"}
  puts $out "  IN [get_atom_port_info -key TYPE -node $n -port_id $i -type iport] <- $fn"
 }
 foreach o [get_atom_oports -node $n] {
  set fo [get_atom_port_info -key FANOUT -node $n -port_id $o -type oport]
  set names {}
  foreach x $fo {catch {lappend names [get_atom_node_info -key NAME -node [lindex $x 0]]}}
  puts $out "  OUT [get_atom_port_info -key TYPE -node $n -port_id $o -type oport] -> [llength $fo]: [lrange $names 0 11]"
 }
}
foreach n $seeds {dump $n SEED}
close $out
project_close -dont_export_assignments
