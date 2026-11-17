load_package atoms
foreach cmd {read_atom_netlist get_atom_nodes get_atom_node_info get_atom_iports get_atom_oports get_atom_port_info get_atom_node_by_name} {
 puts "COMMAND $cmd"
 if {[catch {$cmd -long_help} txt]} {puts "HELP_RETURN $txt"} else {puts $txt}
}
