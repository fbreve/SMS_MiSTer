onerror {quit -code 1}
onbreak {quit -code 1}
vlib f13_work
vcom -work f13_work -2008 -quiet ../../rtl/mapper_detect.vhd f13_mapper_ctrl_sim.vhd ../../rtl/memory_decode.vhd
vlog -work f13_work -sv -quiet savestates_sim.sv f13_machine.sv f13_history_tb.sv
vsim -c -t 1ps -voptargs=+acc f13_work.history_tb -gCASE=$env(F13_CASE)
set NumericStdNoWarnings 1
run -all
quit -code 0
