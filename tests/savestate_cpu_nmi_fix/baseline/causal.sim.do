onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps -voptargs=+acc nmi_causal_work.nmi_tb -gEDGE=$env(NMI_EDGE) -gWIDTH=$env(NMI_WIDTH) -gSOURCE=$env(NMI_SOURCE) -gPROGRAM=$env(NMI_PROGRAM) -gRUN=$env(NMI_RUN) -gTARGET=$env(NMI_TARGET) -gINJECT=1
set NumericStdNoWarnings 1
run -all
quit -code 0


