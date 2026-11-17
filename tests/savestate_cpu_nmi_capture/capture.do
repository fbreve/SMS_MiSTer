onerror {quit -code 1}
onbreak {quit -code 1}
vlib capture_work
vcom -work capture_work -2008 -quiet ../../rtl/video.vhd ../../rtl/io.vhd ../../rtl/T80/T80_Reg.vhd ../../rtl/T80/T80_MCode.vhd ../../rtl/T80/T80_ALU.vhd T80_candidate.vhd T80s_candidate.vhd
vlog -work capture_work -sv -quiet savestates_sim.sv capture_tb.sv
vsim -c -t 1ps -voptargs=+acc capture_work.capture_tb -gCAND=$env(CAP_CAND) -gEDGE=$env(CAP_EDGE) -gWIDTH=$env(CAP_WIDTH) -gSOURCE=$env(CAP_SOURCE) -gPROGRAM=$env(CAP_PROGRAM) -gSECOND=$env(CAP_SECOND) -gHELD=$env(CAP_HELD) -gBAD=$env(CAP_BAD) -gTARGET=359
set NumericStdNoWarnings 1
run -all
quit -code 0
