onerror {quit -code 1}
onbreak {quit -code 1}
vlib final_work
vcom -work final_work -2008 -quiet ../../../rtl/video.vhd ../../../rtl/io.vhd ../../../rtl/T80/T80_Reg.vhd ../../../rtl/T80/T80_MCode.vhd ../../../rtl/T80/T80_ALU.vhd T80_integrated.vhd T80s_integrated.vhd
vlog -work final_work -sv -quiet savestates_integrated.sv machine.sv fixed_tb.sv
vsim -c -t 1ps -voptargs=+acc final_work.fixed_tb -gSOURCE=$env(FIX_SOURCE) -gPROGRAM=$env(FIX_PROGRAM) -gEDGE=$env(FIX_EDGE) -gWIDTH=$env(FIX_WIDTH) -gSECOND=$env(FIX_SECOND) -gHELD=$env(FIX_HELD) -gSCHEDULE=$env(FIX_SCHEDULE) -gFORMAT=$env(FIX_FORMAT) -gRELEASE_SECOND=1
set NumericStdNoWarnings 1
run -all
quit -code 0

