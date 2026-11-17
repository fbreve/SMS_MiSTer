package require ::quartus::project
package require ::quartus::sta
project_open [lindex $quartus(args) 0]
create_timing_netlist -model slow
read_sdc
update_timing_netlist
set starts [get_keepers -nowarn *HDMI_shadowmask*]
set ends [get_keepers -nowarn *hdmi_osd*h_cnt*]
puts "Shadowmask keepers: [get_collection_size $starts]; OSD counter keepers: [get_collection_size $ends]"
if {[get_collection_size $starts] > 0 && [get_collection_size $ends] > 0} {
 report_timing -setup -from $starts -to $ends -npaths 5 -detail full_path -show_routing -file physical_shadowmask_osd.rpt
}
delete_timing_netlist
project_close -dont_export_assignments
