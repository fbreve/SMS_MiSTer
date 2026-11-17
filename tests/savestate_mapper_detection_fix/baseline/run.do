onerror {quit -code 1}
onbreak {quit -code 1}
vlib work
vcom -2008 -quiet ../../rtl/mapper_detect.vhd mapper_ctrl_sim.vhd ../../rtl/memory_decode.vhd
vlog -sv -quiet savestates_sim.sv machine.sv history_tb.sv
vsim -c -t 1ps -voptargs=+acc work.history_tb -gCASE=$env(F13_CASE)
set NumericStdNoWarnings 1
run -all
quit -code 0
