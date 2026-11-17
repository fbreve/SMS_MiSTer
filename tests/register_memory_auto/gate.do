onerror {quit -code 1}
onbreak {quit -code 1}
vlib gate_work
vlog -quiet -work gate_work RegisterMemory_gate.vo
vcom -2008 -quiet -work test_work gate_tb.vhd
vsim -c -t 1ps -L gate_work -L cyclonev_ver -L altera_ver -L altera_mf_ver -L altera_lnsim_ver -L sgate_ver test_work.gate_tb
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
