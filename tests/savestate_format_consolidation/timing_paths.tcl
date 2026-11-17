package require ::quartus::project
package require ::quartus::sta
set project [lindex $quartus(args) 0]
set out [lindex $quartus(args) 1]
project_open $project
create_timing_netlist
read_sdc
update_timing_netlist
report_timing -setup -npaths 10 -detail full_path -file "${out}_setup.rpt"
report_timing -hold -npaths 10 -detail full_path -file "${out}_hold.rpt"
delete_timing_netlist
project_close
