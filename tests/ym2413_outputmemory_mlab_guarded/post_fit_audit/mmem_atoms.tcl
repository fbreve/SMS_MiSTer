package require ::quartus::project
package require ::quartus::atoms
project_open W:/candidate/SMS
read_atom_netlist -type cmp
set out [open [lindex $argv 1] w]
foreach_in_collection n [get_atom_nodes] {
 set name [get_atom_node_info -key NAME -node $n]
 if {[string match *OutputMemory:Mmem* $name]} {
  puts $out "ATOM\t$n\t[get_atom_node_info -key TYPE -node $n]\t[get_atom_node_info -key LOCATION -node $n]\t$name"
  foreach k {STRING_DEFPARAMS ENUM_OUTPUT_REGISTER_MODE ENUM_OPERATION_MODE} {set code [catch {get_atom_node_info -key $k -node $n} m];puts $out "PARAM\t$k\t$code\t$m"}
  foreach i [get_atom_iports -node $n] {
   set f [get_atom_port_info -key FANIN -node $n -port_id $i -type iport]
   set fname {};if {[llength $f]>0} {set fname [get_atom_node_info -key NAME -node [lindex $f 0]]}
   puts $out "IN\t$i\t[get_atom_port_info -key TYPE -node $n -port_id $i -type iport]\t$f\t$fname"
  }
  foreach o [get_atom_oports -node $n] {puts $out "OUT\t$o\t[get_atom_port_info -key TYPE -node $n -port_id $o -type oport]\t[get_atom_port_info -key FANOUT -node $n -port_id $o -type oport]"}
 }
}
close $out
project_close -dont_export_assignments


