load_package atoms
project_open SMS
read_atom_netlist -type map
set k 0
foreach_in_collection n [get_atom_nodes] {
 set name [get_atom_node_info -node $n -key name]
 if {[string match {*spr_x*} $name] || [string match {*spr_d3*} $name]} {
 puts "NODE $n $name [get_atom_node_info -node $n -key type]"
 incr k
 if {$k>=10} {break}
 }
}
puts "CMDS [info commands *atom*]"
project_close -dont_export_assignments
