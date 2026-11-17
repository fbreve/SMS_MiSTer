onerror {quit -code 1}
onbreak {quit -code 1}
vlib fixed_work
vcom -work fixed_work -2008 -quiet ../../../rtl/video.vhd ../../../rtl/io.vhd ../../../rtl/T80/T80_Reg.vhd ../../../rtl/T80/T80_MCode.vhd ../../../rtl/T80/T80_ALU.vhd T80_observed.vhd T80s_observed.vhd
vlog -work fixed_work -sv -quiet savestates_sim.sv machine.sv fixed_tb.sv
vsim -c -t 1ps -voptargs=+acc fixed_work.fixed_tb -gSOURCE=0 -gPROGRAM=0 -gEDGE=0 -gWIDTH=1 -gSECOND=9999999 -gHELD=0 -gSCHEDULE=0 -gFORMAT=0
set NumericStdNoWarnings 1
run -all
quit -code 0

