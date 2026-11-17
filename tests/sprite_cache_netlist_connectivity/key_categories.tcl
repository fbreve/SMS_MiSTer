load_package atoms
foreach type {bitvec string enum bool int} {puts "KEYS $type";catch {get_legal_info_keys -type $type} v;puts $v}
