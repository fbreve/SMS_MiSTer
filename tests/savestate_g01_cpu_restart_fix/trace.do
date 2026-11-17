onerror {quit -code 1}
onbreak {quit -code 1}
vlib trace_work
vcom -work trace_work -2008 -quiet ../../rtl/video.vhd ../../rtl/io.vhd ../../rtl/T80/T80_Reg.vhd ../../rtl/T80/T80_MCode.vhd ../../rtl/T80/T80_ALU.vhd T80_integrated.vhd T80s_integrated.vhd mapper_ctrl_observed.vhd ../../rtl/mapper_detect.vhd ../../rtl/memory_decode.vhd
vlog -work trace_work -sv -quiet savestates_integrated.sv mapping.sv integrated_machine.sv trace_tb.sv
vsim -c -t 1ps trace_work.fixed_tb -gPROGRAM=$env(G09_PROGRAM) -gOFFSET=$env(G09_OFFSET) -gPERIOD=$env(G09_PERIOD) -gSYS=$env(G09_SYS) -gCAPTURES=$env(G09_CAPTURES) -gSIGNATURE=$env(G01_SIGNATURE) -gINTCASE=$env(G01_INTCASE)
set NumericStdNoWarnings 1
run -all
quit -code 0
