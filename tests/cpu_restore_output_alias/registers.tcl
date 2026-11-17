package require ::quartus::project
package require ::quartus::sta
project_open [lindex $quartus(args) 0]
create_timing_netlist
read_sdc
update_timing_netlist
set out [open [lindex $quartus(args) 1] w]
puts $out "name"
set regs [get_registers -nowarn {*savestates_inst|*}]
puts "ALIAS_REGISTER_NODES [get_collection_size $regs]"
foreach_in_collection r $regs {puts $out [get_node_info $r -name]}
close $out
delete_timing_netlist
project_close
