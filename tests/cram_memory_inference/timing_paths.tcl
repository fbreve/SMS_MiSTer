package require ::quartus::project
package require ::quartus::sta
project_open [lindex $quartus(args) 0]
set out [lindex $quartus(args) 1]
create_timing_netlist
read_sdc
update_timing_netlist
report_timing -setup -npaths 10 -detail full_path -file "${out}_setup.rpt"
report_timing -hold -npaths 10 -detail full_path -file "${out}_hold.rpt"
set emu [get_clocks {*emu|pll|pll_inst|*divclk}]
if {[get_collection_size $emu] != 1} {error "Expected one emulation clock"}
report_timing -setup -from_clock $emu -to_clock $emu -npaths 10 -detail full_path -file "${out}_core.rpt"
set palette [get_registers {*vdp_cram_inst*}]
puts "CRAM timing register nodes: [get_collection_size $palette]"
if {[get_collection_size $palette] > 0} {
 report_timing -setup -from $palette -npaths 10 -detail full_path -file "${out}_cram_from.rpt"
 report_timing -setup -to $palette -npaths 10 -detail full_path -file "${out}_cram_to.rpt"
}
delete_timing_netlist
project_close
