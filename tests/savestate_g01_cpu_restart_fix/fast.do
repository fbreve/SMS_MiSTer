onerror {quit -code 1}
onbreak {quit -code 1}
vlib fast_work
vcom -work fast_work -2008 -quiet ../../rtl/video.vhd ../../rtl/io.vhd ../../rtl/T80/T80_Reg.vhd ../../rtl/T80/T80_MCode.vhd ../../rtl/T80/T80_ALU.vhd T80_proof.vhd T80s_proof.vhd mapper_ctrl_observed.vhd ../../rtl/mapper_detect.vhd ../../rtl/memory_decode.vhd
vlog -work fast_work -sv -quiet savestates_fast.sv mapping.sv proof_machine.sv proof_tb.sv
vsim -c -t 1ps fast_work.fixed_tb -gPROGRAM=$env(G09_PROGRAM) -gOFFSET=$env(G09_OFFSET) -gPERIOD=$env(G09_PERIOD) -gSYS=$env(G09_SYS) -gCAPTURES=$env(G09_CAPTURES) -gSIGNATURE=$env(G01_SIGNATURE)
set NumericStdNoWarnings 1
run -all
quit -code 0

