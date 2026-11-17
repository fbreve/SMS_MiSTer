package require ::quartus::project
package require ::quartus::sta
project_open [lindex $quartus(args) 0]
create_timing_netlist
read_sdc
update_timing_netlist
set out [lindex $quartus(args) 1]
foreach cmd {get_fanouts get_node_info} {puts [help -cmd $cmd]}
set f [open ${out}_fanout_valid.tsv w]
foreach_in_collection r [get_registers {*savestates_inst|z80_*}] {
 set n [get_node_info $r -name]
 puts $f "$n\t[get_collection_size [get_fanouts [get_registers $n]]]"
}
close $f
delete_timing_netlist
project_close
