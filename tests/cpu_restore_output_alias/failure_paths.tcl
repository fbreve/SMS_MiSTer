package require ::quartus::project
package require ::quartus::sta
project_open [lindex $quartus(args) 0]
create_timing_netlist
read_sdc
update_timing_netlist
report_timing -setup -npaths 5 -detail full_path -show_routing -file [lindex $quartus(args) 1]
set core [get_clocks {*emu|pll*}]
report_timing -setup -from_clock $core -to_clock $core -npaths 1 -detail full_path -show_routing -file [lindex $quartus(args) 2]
delete_timing_netlist
project_close
