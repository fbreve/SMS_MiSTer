onerror {quit -code 1}
onbreak {quit -code 1}
vcom -2008 -quiet -work test_work opll_gate_wrappers.vhd
vlog -sv -quiet -work test_work savestate_gate_tb.sv
if {![info exists env(GATE_REFERENCE)]} {set env(GATE_REFERENCE) 0}
vsim -c -t 1ps -L test_work -L gate_work -L cyclonev_ver -L altera_ver -L altera_mf_ver -L altera_lnsim_ver -L sgate_ver test_work.savestate_gate_tb -gREF=$env(GATE_REFERENCE)
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
