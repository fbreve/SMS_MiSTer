package require ::quartus::project
package require ::quartus::sta
project_open [lindex $quartus(args) 0]
create_timing_netlist
read_sdc
update_timing_netlist
set out [lindex $quartus(args) 1]
foreach spec {{hdmi {*pll_hdmi*}} {core {*emu|pll*}}} {
 lassign $spec label pat
 set clocks [get_clocks $pat]
 foreach type {setup hold} {
 report_timing -$type -from_clock $clocks -to_clock $clocks -npaths 50 -nworst 1 -detail full_path -show_routing -file ${out}_${label}_${type}.txt
 }
}
foreach spec {{hcnt {*shadowmask:HDMI_shadowmask*ram_block5a0} {*osd:hdmi_osd|h_cnt*}} {width {*shadowmask:HDMI_shadowmask*ram_block5a0} {*osd:hdmi_osd|dsp_width*}} {alias {*savestates_inst|z80_snap*} {*T80*}} {dir {*savestates_inst|z80_dir*} {*T80*}}} {
 lassign $spec label fp tp
 report_timing -setup -from [get_registers -nowarn $fp] -to [get_registers -nowarn $tp] -npaths 50 -nworst 1 -detail full_path -show_routing -file ${out}_${label}.txt
}
set f [open ${out}_registers.tsv w]
foreach_in_collection r [get_registers *] {puts $f [get_node_info $r -name]}
close $f
foreach cmd {get_timing_paths get_path_info get_node_info} {catch {help -long $cmd}}
delete_timing_netlist
project_close
