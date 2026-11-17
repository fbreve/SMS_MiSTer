onerror {quit -code 1}
onbreak {quit -code 1}
vlib extended_work
vcom -work extended_work -2008 -quiet ../../rtl/video.vhd ../../rtl/io.vhd ../../rtl/T80/T80_Reg.vhd ../../rtl/T80/T80_MCode.vhd ../../rtl/T80/T80_ALU.vhd T80_context.vhd T80s_context.vhd mapper_ctrl_observed.vhd ../../rtl/mapper_detect.vhd ../../rtl/memory_decode.vhd
vlog -work extended_work -sv -quiet savestates_sim.sv mapping.sv extended_machine.sv extended_tb.sv
vsim -c -t 1ps extended_work.fixed_tb -gPROGRAM=$env(G09_PROGRAM) -gOFFSET=$env(G09_OFFSET) -gPERIOD=$env(G09_PERIOD) -gSYS=$env(G09_SYS) -gCAPTURES=0 -gSIGNATURE=$env(G01_SIGNATURE)
set NumericStdNoWarnings 1
run -all
quit -code 0
