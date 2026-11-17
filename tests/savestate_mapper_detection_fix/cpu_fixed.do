onerror {quit -code 1}
onbreak {quit -code 1}
vlib cpu_work
vcom -work cpu_work -2008 -quiet ../../rtl/video.vhd ../../rtl/mapper_detect.vhd mapper_ctrl_sim.vhd ../../rtl/memory_decode.vhd ../../rtl/T80/T80_Reg.vhd ../../rtl/T80/T80_MCode.vhd ../../rtl/T80/T80_ALU.vhd T80_sim.vhd T80s_sim.vhd
vlog -work cpu_work -sv -quiet savestates_sim.sv machine.sv cpu_fixed_tb.sv
vsim -c -t 1ps -voptargs=+acc cpu_work.cpu_reach_tb -gEARLY=$env(F13_EARLY)
set NumericStdNoWarnings 1
run -all
quit -code 0
