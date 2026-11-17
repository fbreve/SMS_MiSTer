package require ::quartus::project
package require ::quartus::sta
project_open [lindex $quartus(args) 0]
create_timing_netlist
read_sdc
update_timing_netlist
set out [lindex $quartus(args) 1]
foreach {label pattern} {
 arm {*savestates_inst|state.ST_ARM_FREEZE}
 restore {*savestates_inst|z80_set}
 vdp2_restore {*savestates_inst|vdp2_regs_set}
 header {*savestates_inst|state.ST_LOAD_HDR_RD}
 legacy {*savestates_inst|has_restart}
 freeze {*savestates_inst|ss_freeze}
 cpu_enable {*emu|ce_cpu}
 vdp_enable {*emu|ce_vdp}
} {
 set regs [get_registers -nowarn $pattern]
 puts "AUDIT_CONTROL $label MATCHES [get_collection_size $regs]"
 if {[get_collection_size $regs]>0} {
  report_timing -setup -from $regs -npaths 3 -detail full_path -file "${out}/${label}_setup.rpt"
 }
}
delete_timing_netlist
project_close
