package require ::quartus::project
package require ::quartus::sta
set project [lindex $quartus(args) 0]
set out [lindex $quartus(args) 1]
project_open $project
create_timing_netlist
read_sdc
update_timing_netlist
set f [open $out w]
puts $f "signal\tregister_nodes\ttransitive_timing_endpoints\tnames"
foreach signal {is_old_format has_audio_ext has_background has_restart has_fm has_nmi_history has_restart_context has_md_ext has_eeprom_tag has_sc_tag has_tap_tag has_paddle_tag has_gun_tag has_mapper_history has_evolution_history evolution_history_valid nmi_padding_ok restart_padding_ok} {
    set regs [get_registers -nowarn "*savestates_inst|${signal}*"]
    set exact [list]
    foreach_in_collection reg $regs {
        set name [get_node_info $reg -name]
        set leaf [lindex [split $name |] end]
        if {[regexp "^${signal}(\\\[|~|$)" $leaf]} { lappend exact $name }
    }
    set count [llength $exact]
    if {$count} {
        set found [get_registers -nowarn $exact]
        set ends [get_fanouts $found]
        puts $f "$signal\t$count\t[get_collection_size $ends]\t[join $exact ,]"
    } else { puts $f "$signal\t0\tUNAVAILABLE\toptimized_or_no_named_register" }
}
close $f
delete_timing_netlist
project_close
