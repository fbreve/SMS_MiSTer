load_package atoms
project_open SMS
read_atom_netlist -type map
foreach args {{} {-type node} {-type iport} {-type oport}} {puts "LEGAL_KEYS_ARGS $args"; catch {eval get_legal_info_keys $args} v;puts $v}
foreach n {57288 57289 57293} {puts "NODE $n [get_atom_node_info -node $n -key name] [get_atom_node_info -node $n -key type]"}
project_close -dont_export_assignments
