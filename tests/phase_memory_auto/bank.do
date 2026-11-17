onerror {quit -code 1}
onbreak {quit -code 1}
vlib baseline_work
vlib candidate_work
vlib test_work
vcom -93 -quiet -work baseline_work baseline/rtl/VM2413/vm2413.vhd baseline/rtl/VM2413/phasememory.vhd
vcom -93 -quiet -work candidate_work candidate/rtl/VM2413/vm2413.vhd candidate/rtl/VM2413/phasememory.vhd
vcom -2008 -quiet -work test_work bank_tb.vhd
vsim -c -t 1ps test_work.bank_tb
run -all
quit -code 0
