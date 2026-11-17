load_package project
set folder [lindex $argv 0]
cd $folder
project_open SMS -revision SMS
set f [open expanded_settings.txt w]
foreach_in_collection assignment [get_all_global_assignments -name *] {puts $f [list GLOBAL $assignment]}
foreach_in_collection assignment [get_all_instance_assignments -name *] {puts $f [list INSTANCE $assignment]}
close $f
set f [open declared_rtl.txt w]
foreach kind {VERILOG_FILE SYSTEMVERILOG_FILE VHDL_FILE} {
 foreach_in_collection assignment [get_all_global_assignments -name $kind] {puts $f "$kind\t[lindex $assignment 2]"}
}
close $f
project_close -dont_export_assignments
