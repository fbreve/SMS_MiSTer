package require ::quartus::sta
foreach cmd {get_path_info get_point_info get_timing_paths report_timing report_sdc report_exceptions} {
 puts "\nHELP $cmd\n"
 catch {$cmd -long_help} msg
 puts $msg
}
