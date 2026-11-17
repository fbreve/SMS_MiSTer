onerror {quit -code 1}
onbreak {quit -code 1}
vlib baseline_work
vlib candidate_work
vlib test_work
foreach variant {baseline candidate} {
 vcom -93 -quiet -work ${variant}_work ${variant}/rtl/VM2413/vm2413.vhd ${variant}/rtl/VM2413/feedbackmemory.vhd FeedbackMemory_flat.vhd
}
vcom -2008 -quiet -work test_work bank_tb.vhd
vsim -c -t 1ps test_work.bank_tb
run -all
quit -code 0
