load_package atoms
project_open SMS
set mode [lindex $quartus(args) 0]
read_atom_netlist -type $mode
set k 0
foreach_in_collection n [get_atom_nodes] {
 set name [get_atom_node_info -node $n -key name]
 if {[regexp {vdp_spr_inst\|spr_(x|d3)\[0\]\[0\]$} $name]} {
 puts "TARGET $n $name"
 foreach key {type location LUT_MASK STRING_LUT_MASK BIT_VEC_LUT_MASK LUTMASK operation_mode} {if {[catch {get_atom_node_info -node $n -key $key} v]} {puts "KEY_ERROR $key $v"} else {puts "KEY $key $v"}}
 puts "IPORTS [get_atom_iports -node $n]"
 foreach ip [get_atom_iports -node $n] {foreach key {name type fanin is_inverted} {if {[catch {get_atom_port_info -node $n -port_id $ip -type iport -key $key} v]} {puts "PORTERR $ip $key $v"} else {puts "PORT $ip $key $v"}}}
 incr k
 if {$k>=1} {break}
 }
}
project_close -dont_export_assignments
