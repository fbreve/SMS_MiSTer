package require ::quartus::project
package require ::quartus::sta
project_open [lindex $quartus(args) 0]
create_timing_netlist
read_sdc
update_timing_netlist
set out [lindex $quartus(args) 1]
set f [open ${out}_locations.tsv w]
foreach pat {{*hdmi_osd*} {*HDMI_shadowmask*} {*savestates_inst|z80_*}} {
 foreach_in_collection r [get_registers $pat] {
 puts $f "[get_node_info $r -name]\t[get_node_info $r -location]\t[llength [get_node_info $r -fanout_edges]]"
 }
}
close $f
foreach spec {{crc {*mapper_detect_inst|rom_crc32*} {*T80:u0|IR*}} {sdram {*sdram:ram|sd_dat*} {*T80:u0|IR*}}} {
 lassign $spec label fp tp
 report_timing -setup -from [get_registers $fp] -to [get_registers $tp] -npaths 50 -nworst 1 -detail full_path -show_routing -file ${out}_${label}.txt
}
delete_timing_netlist
project_close
