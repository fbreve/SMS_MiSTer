onerror {quit -code 1}
onbreak {quit -code 1}
vlib work
vcom -work work -2008 -quiet ../../rtl/video.vhd ../../rtl/io.vhd ../../rtl/T80/T80_Reg.vhd ../../rtl/T80/T80_MCode.vhd ../../rtl/T80/T80_ALU.vhd T80_observed.vhd T80s_observed.vhd mapper_ctrl_observed.vhd ../../rtl/mapper_detect.vhd ../../rtl/memory_decode.vhd
vlog -work work -sv -quiet savestates_sim.sv mapping.sv machine.sv fixed_tb.sv
vsim -c -t 1ps work.fixed_tb -gPROGRAM=$env(G09_PROGRAM) -gOFFSET=$env(G09_OFFSET) -gPERIOD=$env(G09_PERIOD) -gSYS=$env(G09_SYS) -gCAPTURES=$env(G09_CAPTURES)
set NumericStdNoWarnings 1
run -all
quit -code 0
