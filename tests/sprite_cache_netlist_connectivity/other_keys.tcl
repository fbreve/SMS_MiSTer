load_package atoms
foreach type {atom_bits object pointer uint uint_vec int_vec string_vec time} {puts "KEYS $type";catch {get_legal_info_keys -type $type} v;puts $v}
