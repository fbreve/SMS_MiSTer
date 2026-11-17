load_package atoms
project_open SMS
puts "OPEN_OK"
set mode [lindex $quartus(args) 0]
if {[catch {read_atom_netlist -type $mode} err]} {puts "READ_ERROR $err";project_close -dont_export_assignments;exit 2}
puts "READ_OK $mode"
set nodes [get_atom_nodes]
puts "NODE_COUNT [get_collection_size $nodes]"
set found 0
foreach_in_collection n $nodes {
 set name [get_atom_node_info -node $n -key name]
 if {[string match {*vdp_spr_inst|spr_d3[[]0[]][[]0[]]} $name] || [string match {*vdp_spr_inst|spr_x[[]0[]][[]0[]]} $name]} {
 puts "TARGET $n $name"
 foreach key {type location LUT_MASK STRING_LUT_MASK BIT_VEC_LUT_MASK LUTMASK operation_mode} {if {[catch {get_atom_node_info -node $n -key $key} v]} {puts "KEY_ERROR $key $v"} else {puts "KEY $key $v"}}
 puts "IPORTS [get_atom_iports -node $n]"
 foreach ip [get_atom_iports -node $n] {puts "IPORT $ip [get_atom_port_info -node $n -port_id $ip -type iport -key name] [get_atom_port_info -node $n -port_id $ip -type iport -key fanin]"}
 incr found
 if {$found>=2} {break}
 }
}
project_close -dont_export_assignments
