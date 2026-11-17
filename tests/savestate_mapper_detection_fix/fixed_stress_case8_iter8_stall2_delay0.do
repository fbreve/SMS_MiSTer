onerror {quit -code 1}
onbreak {quit -code 1}
vlib fixed_stress_case8_iter8_stall2_delay0_work
vcom -work fixed_stress_case8_iter8_stall2_delay0_work -2008 -quiet ../../rtl/mapper_detect.vhd mapper_ctrl_sim.vhd ../../rtl/memory_decode.vhd
vlog -work fixed_stress_case8_iter8_stall2_delay0_work -sv -quiet savestates_sim.sv machine.sv history_tb.sv
vsim -c -t 1ps -voptargs=+acc fixed_stress_case8_iter8_stall2_delay0_work.history_tb -gCASE=8 -gITERATIONS=8 -gSTALL=2 -gSAVE_DELAY=0
set NumericStdNoWarnings 1
run -all
quit -code 0
