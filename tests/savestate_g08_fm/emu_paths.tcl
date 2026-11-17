package require ::quartus::project
package require ::quartus::sta
set project [lindex $quartus(args) 0]
set out [lindex $quartus(args) 1]
project_open $project
create_timing_netlist
read_sdc
update_timing_netlist
set emu [get_clocks {*emu|pll|pll_inst|*divclk}]
if {[get_collection_size $emu] != 1} { error "Expected one emulation clock" }
report_timing -setup -from_clock $emu -to_clock $emu -npaths 10 -detail full_path -file $out
delete_timing_netlist
project_close
