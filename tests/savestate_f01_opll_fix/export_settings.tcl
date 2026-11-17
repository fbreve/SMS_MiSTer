load_package project
set folder [lindex $argv 0]
set output [lindex $argv 1]
cd $folder
project_open SMS -revision SMS
set f [open $output w]
foreach_in_collection assignment [get_all_global_assignments -name *] {
    puts $f [list GLOBAL $assignment]
}
foreach_in_collection assignment [get_all_instance_assignments -name *] {
    puts $f [list INSTANCE $assignment]
}
close $f
project_close -dont_export_assignments
