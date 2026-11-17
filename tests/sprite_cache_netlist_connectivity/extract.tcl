load_package atoms
project_open SMS
set stage [lindex $quartus(args) 0]
read_atom_netlist -type $stage
set out [open "../${stage}_cones.tsv" w]
puts $out "META\tstage\t$stage"
set roots {}
foreach_in_collection n [get_atom_nodes] {
 set name [get_atom_node_info -node $n -key name]
 if {[regexp {vdp_spr_inst\|spr_(x|d3)\[(0|7|8|31|32|63)\]\[[0-7]\](~DUPLICATE.*)?$} $name]} {
  if {[get_atom_node_info -node $n -key type] eq "FF"} {lappend roots $n;puts $out "R\t$n\t$name"}
 }
}
puts "ROOTS [llength $roots]"
array set isroot {};foreach n $roots {set isroot($n) 1}
set queue $roots
array set seen {}
set count 0
while {[llength $queue]>0} {
 set n [lindex $queue 0];set queue [lrange $queue 1 end]
 if {[info exists seen($n)]} {continue}
 set seen($n) 1;incr count
 if {$count>5000} {error "BOUND_EXCEEDED 5000 atoms"}
 set name [get_atom_node_info -node $n -key name]
 set type [get_atom_node_info -node $n -key type]
 set loc "NA_POST_MAP"
 if {$stage eq "cmp"} {if {[catch {get_atom_node_info -node $n -key location} loc]} {set loc "UNAVAILABLE"}}
 puts $out "N\t$n\t$type\t$loc\t$name"
 foreach op [get_atom_oports -node $n] {
  set ot [get_atom_port_info -node $n -port_id $op -type oport -key type]
  if {[catch {get_atom_port_info -node $n -port_id $op -type oport -key lutmask} mask]} {set mask "UNAVAILABLE"}
  set fo [get_atom_port_info -node $n -port_id $op -type oport -key fanout]
  puts $out "O\t$n\t$op\t$ot\t$mask\t$fo"
 }
 if {$type eq "LCELL_COMB" || [info exists isroot($n)]} {
  foreach ip [get_atom_iports -node $n] {
   set it [get_atom_port_info -node $n -port_id $ip -type iport -key type]
   if {[info exists isroot($n)] && [string match {*CLK*} $it]} {continue}
   set inv [get_atom_port_info -node $n -port_id $ip -type iport -key is_inverted]
   set fi [get_atom_port_info -node $n -port_id $ip -type iport -key fanin]
   set g [get_atom_port_info -node $n -port_id $ip -type iport -key is_logical_gnd]
   set v [get_atom_port_info -node $n -port_id $ip -type iport -key is_logical_vcc]
   puts $out "I\t$n\t$ip\t$it\t$inv\t$fi\t$g\t$v"
   if {[llength $fi]==2} {lappend queue [lindex $fi 0]}
  }
 }
}
puts $out "DONE\t$count"
close $out
puts "EXTRACTED $stage $count"
unload_atom_netlist
project_close -dont_export_assignments
