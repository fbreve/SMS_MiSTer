package require ::quartus::project
package require ::quartus::sta
project_open [lindex $quartus(args) 0]
set out [lindex $quartus(args) 1]
create_timing_netlist -model slow
read_sdc
update_timing_netlist
foreach {label from_pattern to_pattern} {
 linebuf {*ascal|*o_linf2*} {*ascal|o_vpix_inner*}
 shadow_osd {*HDMI_shadowmask|*vid_rtl_0*} {*hdmi_osd|osd_div*}
 counter {*ascal|o_hcpt*} {*ascal|o_vcpt_pre3*}
 poly_lum {*ascal|o_vpix_inner*} {*ascal|o_poly_lum*}
} {
 set src [get_registers $from_pattern];set dst [get_registers $to_pattern]
 puts "FAMILY $label FROM [get_collection_size $src] TO [get_collection_size $dst]"
 if {[get_collection_size $src]>0 && [get_collection_size $dst]>0} {
  report_timing -setup -from $src -to $dst -npaths 5 -nworst 2 -detail full_path -show_routing -file "${out}_${label}.rpt"
 }
}
delete_timing_netlist
project_close
