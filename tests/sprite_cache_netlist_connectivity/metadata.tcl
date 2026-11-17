load_package atoms
project_open SMS
set stage [lindex $quartus(args) 0]
read_atom_netlist -type $stage
set f [open "../${stage}_metadata_ids.txt" r]
set ids [split [string trim [read $f]] "\n"];close $f
if {[llength $ids]>5000} {error "METADATA_BOUND"}
set f [open "../${stage}_metadata.tsv" w]
foreach n $ids {
 set name [get_atom_node_info -node $n -key name]
 set type [get_atom_node_info -node $n -key type]
 set loc "NA_POST_MAP";if {$stage eq "cmp"} {set loc [get_atom_node_info -node $n -key location]}
 puts $f "N\t$n\t$type\t$loc\t$name"
 if {$type eq "LCELL_COMB"} {
  foreach key {NORMAL SHARED_ARITH EXTENDED_LUT CIN_TO_SUM DATAC_TO_SUM ONE_LEVEL_ADDER TWO_LEVEL_ADDER TWO_LEVEL_ADDER_CHAIN_OUT ENUM_LCELL_MODE BOOL_SUM_LUT_IS_USED BOOL_CARRY_LUT_IS_USED} {
   if {[catch {get_atom_node_info -node $n -key $key} v]} {set v "UNAVAILABLE"}
   puts $f "K\t$n\t$key\t$v"
  }
 }
}
puts $f "DONE\t[llength $ids]"
close $f
unload_atom_netlist
project_close -dont_export_assignments
