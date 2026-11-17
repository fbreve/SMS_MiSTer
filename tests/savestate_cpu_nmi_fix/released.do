onerror {quit -code 1}
onbreak {quit -code 1}
vlib released_work
vcom -work released_work -2008 -quiet ../../rtl/video.vhd ../../rtl/io.vhd ../../rtl/T80/T80_Reg.vhd ../../rtl/T80/T80_MCode.vhd ../../rtl/T80/T80_ALU.vhd T80_observed.vhd T80s_observed.vhd
vlog -work released_work -sv -quiet savestates_sim.sv machine.sv released_tb.sv
vsim -c -t 1ps -voptargs=+acc released_work.released_tb -gSOURCE=$env(FIX_SOURCE) -gPROGRAM=$env(FIX_PROGRAM) -gEDGE=$env(FIX_EDGE) -gWIDTH=$env(FIX_WIDTH) -gSECOND=$env(FIX_SECOND) -gHELD=$env(FIX_HELD) -gSCHEDULE=$env(FIX_SCHEDULE) -gFORMAT=$env(FIX_FORMAT)
set NumericStdNoWarnings 1
run -all
quit -code 0
