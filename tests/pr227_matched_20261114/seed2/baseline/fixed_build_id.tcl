set f [open "build_id.v" w]
puts -nonewline $f {`define BUILD_DATE "261114"}
close $f
