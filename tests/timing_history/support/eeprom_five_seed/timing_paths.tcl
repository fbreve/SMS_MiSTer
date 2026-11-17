package require ::quartus::project
package require ::quartus::sta
project_open SMS -revision SMS
create_timing_netlist -model slow
read_sdc
update_timing_netlist
report_timing -setup -npaths 10 -detail full_path -file [lindex $quartus(args) 0]
delete_timing_netlist
project_close
