onerror {quit -code 1}
onbreak {quit -code 1}
vlib model_work
vmap work model_work
vcom -2008 -quiet sim_rtl/vm2413.vhd sim_rtl/slotcounter.vhd sim_rtl/voicerom.vhd sim_rtl/voicememory.vhd sim_rtl/registermemory.vhd sim_rtl/attacktable.vhd sim_rtl/envelopememory.vhd sim_rtl/envelopegenerator.vhd sim_rtl/phasememory.vhd sim_rtl/phasegenerator.vhd sim_rtl/sinetable.vhd sim_rtl/operator.vhd sim_rtl/feedbackmemory.vhd sim_rtl/outputmemory.vhd sim_rtl/lineartable.vhd sim_rtl/outputgenerator.vhd sim_rtl/temporalmixer.vhd sim_rtl/controller.vhd sim_rtl/opll.vhd ablation_tb.vhd
vsim -t 1ps work.ablation_tb -gFOLLOW=1200 -gOMIT_LO=91 -gOMIT_HI=92
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
