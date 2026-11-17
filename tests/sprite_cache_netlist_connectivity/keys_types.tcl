load_package atoms
foreach a {{-type atom_node} {-type atom_port} {-type node_info} {-type atom_node_info} {-type atom_port_info} {-type LCELL_COMB}} {puts "TRY $a";catch {eval get_legal_info_keys $a} v;puts $v}
