package require ::quartus::project
package require ::quartus::sta
project_open [lindex $quartus(args) 0]
set out [lindex $quartus(args) 1]
create_timing_netlist
read_sdc
update_timing_netlist
report_timing -setup -npaths 10 -detail full_path -file "${out}_setup.rpt"
report_timing -hold -npaths 10 -detail full_path -file "${out}_hold.rpt"
set fm [get_keepers {*emu|system|fm|*}]
set phase [get_keepers {*emu|system|fm|pg|MEM|*}]
puts "FM keepers: [get_collection_size $fm]; PhaseMemory keepers: [get_collection_size $phase]"
if {[get_collection_size $fm] > 0} {
 report_timing -setup -from $fm -npaths 5 -detail full_path -file "${out}_fm_from.rpt"
 report_timing -setup -to $fm -npaths 5 -detail full_path -file "${out}_fm_to.rpt"
}
if {[get_collection_size $phase] > 0} {
 report_timing -setup -from $phase -npaths 5 -detail full_path -file "${out}_phase_from.rpt"
 report_timing -setup -to $phase -npaths 5 -detail full_path -file "${out}_phase_to.rpt"
}
delete_timing_netlist
project_close
