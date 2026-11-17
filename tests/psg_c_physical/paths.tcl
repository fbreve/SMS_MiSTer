package require ::quartus::project
package require ::quartus::sta
project_open [lindex $quartus(args) 0]
set out [lindex $quartus(args) 1]
create_timing_netlist -model slow
read_sdc
update_timing_netlist
report_timing -setup -npaths 10 -nworst 3 -detail full_path -show_routing -file "${out}_setup.rpt"
report_timing -hold -npaths 5 -nworst 2 -detail full_path -show_routing -file "${out}_hold.rpt"
report_sdc -ignored -file "${out}_ignored_sdc.rpt"
delete_timing_netlist
project_close
