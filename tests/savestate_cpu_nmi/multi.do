onerror {quit -code 1}
onbreak {quit -code 1}
vlib nmi_multi_work
vcom -work nmi_multi_work -2008 -quiet ../../rtl/video.vhd ../../rtl/io.vhd ../../rtl/T80/T80_Reg.vhd ../../rtl/T80/T80_MCode.vhd ../../rtl/T80/T80_ALU.vhd T80_observed.vhd T80s_observed.vhd
vlog -work nmi_multi_work -sv -quiet savestates_sim.sv nmi_tb.sv
vsim -c -t 1ps -voptargs=+acc nmi_multi_work.nmi_tb -gEDGE=$env(NMI_EDGE) -gWIDTH=$env(NMI_WIDTH) -gSOURCE=$env(NMI_SOURCE) -gPROGRAM=$env(NMI_PROGRAM) -gRUN=$env(NMI_RUN) -gTARGET=$env(NMI_TARGET) -gSECOND=-15 -gWIDTH2=5
set NumericStdNoWarnings 1
run -all
quit -code 0

