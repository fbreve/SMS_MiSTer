package require ::quartus::project
package require ::quartus::sta
project_open [lindex $quartus(args) 0]
create_timing_netlist
read_sdc
update_timing_netlist
set out [lindex $quartus(args) 1]
foreach cmd {get_timing_paths get_path_info get_node_info get_fanouts report_timing} {catch {puts [help -long $cmd]}}
foreach spec {{cpu_all {*} {*T80*}} {snapdir {*savestates_inst|z80_snap*} {*savestates_inst|z80_dir*}} {cpu_restore {*savestates_inst|z80_*} {*T80*}}} {
 lassign $spec label fp tp
 set f [get_registers -nowarn $fp];set t [get_registers -nowarn $tp]
 if {[get_collection_size $f] && [get_collection_size $t]} {
 foreach type {setup hold} {report_timing -$type -from $f -to $t -npaths 50 -nworst 1 -detail full_path -show_routing -file ${out}_${label}_${type}.txt}
 }
}
set f [open ${out}_fanout.tsv w]
foreach_in_collection r [get_registers {*savestates_inst|z80_*}] {
 set n [get_node_info $r -name]
 catch {puts $f "$n\t[get_collection_size [get_fanouts $r]]"}
}
close $f
delete_timing_netlist
project_close
