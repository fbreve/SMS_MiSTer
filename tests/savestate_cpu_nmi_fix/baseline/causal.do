onerror {quit -code 1}
onbreak {quit -code 1}
vlib nmi_causal_work
vcom -work nmi_causal_work -2008 -quiet ../../../rtl/video.vhd ../../../rtl/io.vhd ../../../rtl/T80/T80_Reg.vhd ../../../rtl/T80/T80_MCode.vhd ../../../rtl/T80/T80_ALU.vhd T80_observed.vhd T80s_observed.vhd
vlog -work nmi_causal_work -sv -quiet savestates_sim.sv nmi_tb.sv
vsim -c -t 1ps -voptargs=+acc nmi_causal_work.nmi_tb -gEDGE=$env(NMI_EDGE) -gWIDTH=$env(NMI_WIDTH) -gSOURCE=$env(NMI_SOURCE) -gPROGRAM=$env(NMI_PROGRAM) -gRUN=$env(NMI_RUN) -gTARGET=$env(NMI_TARGET) -gINJECT=1
set NumericStdNoWarnings 1
run -all
quit -code 0


