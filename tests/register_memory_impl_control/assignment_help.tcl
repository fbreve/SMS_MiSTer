package require ::quartus::project
foreach name {PHYSICAL_SYNTHESIS_EFFORT PHYSICAL_SYNTHESIS_REGISTER_RETIMING ALLOW_REGISTER_RETIMING PLACEMENT_EFFORT_MULTIPLIER FITTER_EFFORT ALM_REGISTER_PACKING_EFFORT AUTO_SHIFT_REGISTER_RECOGNITION PLACE_REGION LL_MEMBER_OF} {
 puts "\nASSIGNMENT $name"
 if {[catch {get_assignment_name_info $name} msg]} {puts "QUERY ERROR $msg"} else {puts $msg}
}
puts "\nPROJECT API HELP"
get_assignment_name_info -long_help
