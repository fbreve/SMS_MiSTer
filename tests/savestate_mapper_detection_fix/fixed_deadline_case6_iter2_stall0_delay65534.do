onerror {quit -code 1}
onbreak {quit -code 1}
vlib fixed_deadline_case6_iter2_stall0_delay65534_work
vcom -work fixed_deadline_case6_iter2_stall0_delay65534_work -2008 -quiet ../../rtl/mapper_detect.vhd mapper_ctrl_sim.vhd ../../rtl/memory_decode.vhd
vlog -work fixed_deadline_case6_iter2_stall0_delay65534_work -sv -quiet savestates_sim.sv machine.sv history_tb.sv
vsim -c -t 1ps -voptargs=+acc fixed_deadline_case6_iter2_stall0_delay65534_work.history_tb -gCASE=6 -gITERATIONS=2 -gSTALL=0 -gSAVE_DELAY=65534
set NumericStdNoWarnings 1
run -all
quit -code 0
