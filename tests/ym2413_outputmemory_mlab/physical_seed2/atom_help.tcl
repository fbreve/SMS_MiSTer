package require ::quartus::atoms
foreach c {get_atom_node_info get_atom_port_info read_atom_netlist get_atom_nodes get_atom_iports} {puts "COMMAND $c";catch {$c} msg;puts $msg}
