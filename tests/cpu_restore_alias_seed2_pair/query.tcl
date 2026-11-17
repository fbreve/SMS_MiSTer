package require ::quartus::project
package require ::quartus::sta
project_open [lindex $quartus(args) 0]
create_timing_netlist
read_sdc
update_timing_netlist
set out [lindex $quartus(args) 1]
foreach type {setup hold} {report_timing -$type -npaths 1000 -nworst 1 -file ${out}_all_${type}.txt}
foreach spec {{hdmi {*pll_hdmi*}} {core {*emu|pll*}}} {
 lassign $spec label pat
 set clocks [get_clocks $pat]
 foreach type {setup hold} {
 report_timing -$type -from_clock $clocks -to_clock $clocks -npaths 50 -nworst 1 -detail full_path -show_routing -file ${out}_${label}_${type}.txt
 }
}
foreach spec {{hcnt {*shadowmask:HDMI_shadowmask*ram_block5a0} {*osd:hdmi_osd|h_cnt*}} {width {*shadowmask:HDMI_shadowmask*ram_block5a0} {*osd:hdmi_osd|dsp_width*}} {alias {*savestates_inst|z80_snap*} {*T80*}} {dir {*savestates_inst|z80_dir*} {*T80*}} {controls {*savestates_inst|z80_*} {*T80*}}} {
 lassign $spec label fp tp
 set f [get_registers -nowarn $fp];set t [get_registers -nowarn $tp]
 if {[get_collection_size $f] && [get_collection_size $t]} {report_timing -setup -from $f -to $t -npaths 50 -nworst 1 -detail full_path -show_routing -file ${out}_${label}.txt}
}
set f [open ${out}_registers.tsv w]
foreach_in_collection r [get_registers *] {puts $f "[get_node_info $r -name]\t[get_node_info $r -location]"}
close $f
puts [help -cmd get_timing_paths]
puts [help -cmd get_path_info]
delete_timing_netlist
project_close

