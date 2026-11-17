load_package atoms
project_open SMS
read_atom_netlist -type map
foreach n {57288 57289 57293} {
 puts "NODE $n [get_atom_node_info -node $n -key name] [get_atom_node_info -node $n -key type]"
 foreach op [get_atom_oports -node $n] {foreach k {type lutmask fanout} {catch {get_atom_port_info -node $n -port_id $op -type oport -key $k} v;puts "OP $op $k $v"}}
 foreach ip [get_atom_iports -node $n] {puts "IP $ip [get_atom_port_info -node $n -port_id $ip -type iport -key type] [get_atom_port_info -node $n -port_id $ip -type iport -key fanin]"}
}
project_close -dont_export_assignments
