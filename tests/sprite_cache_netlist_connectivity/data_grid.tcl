load_package atoms
project_open SMS
set stage [lindex $quartus(args) 0]
read_atom_netlist -type $stage
set f [open "../${stage}_data_grid.tsv" w]
array set dumped {}
set roots 0
foreach_in_collection n [get_atom_nodes] {
 set name [get_atom_node_info -node $n -key name]
 if {![regexp {vdp_spr_inst\|spr_(x|d3)\[[0-9]+\]\[[0-7]\](~DUPLICATE.*)?$} $name]} {continue}
 if {[get_atom_node_info -node $n -key type] ne "FF"} {continue}
 incr roots
 if {$roots>2400} {error "ROOT_BOUND"}
 set loc "NA_POST_MAP";if {$stage eq "cmp"} {set loc [get_atom_node_info -node $n -key location]}
 foreach ip [get_atom_iports -node $n] {
  set it [get_atom_port_info -node $n -port_id $ip -type iport -key type]
  if {$it ne "D"} {continue}
  set fi [get_atom_port_info -node $n -port_id $ip -type iport -key fanin]
  puts $f "R\t$n\t$name\t$loc\t$fi"
  if {[llength $fi]!=2} {continue}
  set q [lindex $fi 0]
  if {[info exists dumped($q)]} {continue}
  set dumped($q) 1
  if {[array size dumped]>2400} {error "DRIVER_BOUND"}
  set qname [get_atom_node_info -node $q -key name]
  set qt [get_atom_node_info -node $q -key type]
  set qloc "NA_POST_MAP";if {$stage eq "cmp"} {set qloc [get_atom_node_info -node $q -key location]}
  puts $f "N\t$q\t$qt\t$qloc\t$qname"
  foreach qp [get_atom_iports -node $q] {
   set ty [get_atom_port_info -node $q -port_id $qp -type iport -key type]
   set inv [get_atom_port_info -node $q -port_id $qp -type iport -key is_inverted]
   set src [get_atom_port_info -node $q -port_id $qp -type iport -key fanin]
   puts $f "I\t$q\t$qp\t$ty\t$inv\t$src"
  }
  foreach op [get_atom_oports -node $q] {
   set fo [get_atom_port_info -node $q -port_id $op -type oport -key fanout]
   if {[llength $fo]==0} {continue}
   set ty [get_atom_port_info -node $q -port_id $op -type oport -key type]
   set mask [get_atom_port_info -node $q -port_id $op -type oport -key lutmask]
   puts $f "O\t$q\t$op\t$ty\t$mask\t$fo"
  }
 }
}
puts $f "DONE\t$roots\t[array size dumped]"
close $f
puts "DATA_GRID $stage roots=$roots drivers=[array size dumped]"
unload_atom_netlist
project_close -dont_export_assignments
