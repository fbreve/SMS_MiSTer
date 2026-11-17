onerror {quit -code 1}
onbreak {quit -code 1}
vlib stalled_work
vcom -work stalled_work -2008 -quiet ../../rtl/video.vhd ../../rtl/io.vhd ../../rtl/T80/T80_Reg.vhd ../../rtl/T80/T80_MCode.vhd ../../rtl/T80/T80_ALU.vhd T80_observed.vhd T80s_observed.vhd
vlog -work stalled_work -sv -quiet savestates_sim.sv machine.sv stalled_tb.sv
vsim -c -t 1ps -voptargs=+acc stalled_work.stalled_tb -gSOURCE=$env(FIX_SOURCE) -gPROGRAM=$env(FIX_PROGRAM) -gEDGE=$env(FIX_EDGE) -gWIDTH=$env(FIX_WIDTH) -gSECOND=$env(FIX_SECOND) -gHELD=$env(FIX_HELD) -gSCHEDULE=$env(FIX_SCHEDULE) -gFORMAT=$env(FIX_FORMAT)
set NumericStdNoWarnings 1
run -all
quit -code 0
