package require ::quartus::project
puts "VERSION $quartus(version)"
if {[catch {load_package atoms} err]} {puts "ATOM_LOAD_ERROR $err"} else {puts "ATOM_LOAD_OK"}
foreach cmd {project_open project_close read_atom_netlist get_atom_nodes get_atom_node_info get_atom_iports get_atom_oports get_atom_port_info get_atom_node_by_name get_atom_netlist_info} {
 puts "COMMAND $cmd PRESENT [llength [info commands $cmd]]"
 if {[llength [info commands $cmd]]} {catch {help -cmd $cmd} txt; puts $txt}
}
