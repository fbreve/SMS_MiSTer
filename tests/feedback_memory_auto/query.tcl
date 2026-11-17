package require ::quartus::project
package require ::quartus::sta
project_open [lindex $quartus(args) 0]
set out [lindex $quartus(args) 1]
create_timing_netlist -model slow
read_sdc
update_timing_netlist
report_timing -setup -npaths 10 -nworst 3 -detail full_path -show_routing -file "${out}_setup.rpt"
set src [get_registers {*ascal|o_vpix_inner*}]
set dst [get_registers {*ascal|o_poly_lum*}]
if {[get_collection_size $src]>0&&[get_collection_size $dst]>0} {report_timing -setup -from $src -to $dst -npaths 3 -detail full_path -show_routing -file "${out}_poly_lum.rpt"}
report_sdc -ignored -file "${out}_ignored_sdc.rpt"
delete_timing_netlist
project_close
