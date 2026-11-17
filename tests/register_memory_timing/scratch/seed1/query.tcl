package require ::quartus::project
package require ::quartus::sta
project_open [lindex $quartus(args) 0]
set out [lindex $quartus(args) 1]
create_timing_netlist -model slow
read_sdc
update_timing_netlist
report_timing -setup -npaths 20 -nworst 3 -detail full_path -show_routing -file "${out}_setup.rpt"
report_sdc -file "${out}_sdc.rpt"
report_sdc -ignored -file "${out}_ignored_sdc.rpt"
report_exceptions -setup -npaths 10 -file "${out}_exceptions.rpt"
set f [open "${out}_paths.tsv" w]
set points [open "${out}_points.tsv" w]
puts $f "rank\tproperty\tvalue"
puts $points "rank\tbranch\ttype\tincrement\ttotal\tlocation\tfanout\tnode"
set rank 0
foreach_in_collection path [get_timing_paths -setup -npaths 20 -nworst 3 -detail full_path] {
 incr rank
 foreach field {slack data_delay clock_skew clock_relationship num_logic_levels arrival_time required_time launch_time latch_time setup_start_multicycle setup_end_multicycle} {puts $f "$rank\t$field\t[get_path_info -$field $path]"}
 foreach field {from to} {puts $f "$rank\t$field\t[get_node_info -name [get_path_info -$field $path]]"}
 foreach field {from_clock to_clock} {puts $f "$rank\t$field\t[get_clock_info -name [get_path_info -$field $path]]"}
 foreach branch {arrival required} {
  foreach_in_collection point [get_path_info -${branch}_points $path] {
   set id [get_point_info -node $point];set name "";if {$id ne ""} {set name [get_node_info -name $id]}
   puts $points "$rank\t$branch\t[get_point_info -type $point]\t[get_point_info -incremental_delay $point]\t[get_point_info -total_delay $point]\t[get_point_info -location $point]\t[get_point_info -number_of_fanout $point]\t$name"
  }
 }
}
close $f
close $points
foreach {label pattern} {fm {*emu|system|fm|*} register {*emu|system|fm|ct|u_register_memory|*} scaler {*ascal|*}} {
 set regs [get_registers $pattern]
 puts "COLLECTION $label [get_collection_size $regs]"
 if {[get_collection_size $regs]>0} {
  report_timing -setup -from $regs -npaths 5 -detail full_path -file "${out}_${label}_from.rpt"
  report_timing -setup -to $regs -npaths 5 -detail full_path -file "${out}_${label}_to.rpt"
 }
}
delete_timing_netlist
project_close
