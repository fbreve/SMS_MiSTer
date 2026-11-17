package require ::quartus::project
package require ::quartus::sta
project_open [lindex $quartus(args) 0]
create_timing_netlist -model slow
read_sdc
update_timing_netlist
report_timing -setup -npaths 10 -nworst 3 -detail full_path -show_routing -file physical_setup.rpt
report_timing -hold -npaths 5 -nworst 2 -detail full_path -show_routing -file physical_hold.rpt
foreach label {fm phase snapshot registers} pattern {*emu|system|fm|* *emu|system|fm|pg|MEM|* *fm_snapshot* *u_register_memory*} {
 set registers [get_keepers -nowarn $pattern]
 puts "$label keepers: [get_collection_size $registers]"
 if {[get_collection_size $registers]>0} {
  report_timing -setup -from $registers -npaths 5 -detail full_path -show_routing -file "physical_${label}_from.rpt"
  report_timing -setup -to $registers -npaths 5 -detail full_path -show_routing -file "physical_${label}_to.rpt"
 }
}
report_sdc -ignored -file physical_ignored_sdc.rpt
report_ucp -file physical_unconstrained.rpt
delete_timing_netlist
project_close -dont_export_assignments
