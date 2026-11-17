package require ::quartus::atoms
foreach t {node_info port_info NODE PORT IPORT ATOM_NODE ATOM_PORT atom_node_info atom_port_info} {catch {get_legal_info_keys -type $t} m;puts "$t -> $m"}
