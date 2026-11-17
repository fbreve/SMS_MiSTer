load_package atoms
foreach type {node-info port-info} {puts "KEYS $type";catch {get_legal_info_keys -type $type} v;puts $v}
