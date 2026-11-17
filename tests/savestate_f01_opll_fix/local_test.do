onerror {quit -code 1}
onbreak {quit -code 1}
vlib original_work
vcom -work original_work -2008 ../savestate_f01_opll_architecture/sim_opll/vm2413.vhd ../savestate_f01_opll_architecture/sim_opll/slotcounter.vhd ../savestate_f01_opll_architecture/sim_opll/voicerom.vhd ../savestate_f01_opll_architecture/sim_opll/voicememory.vhd ../savestate_f01_opll_architecture/sim_opll/registermemory.vhd ../savestate_f01_opll_architecture/sim_opll/attacktable.vhd ../savestate_f01_opll_architecture/sim_opll/envelopememory.vhd ../savestate_f01_opll_architecture/sim_opll/envelopegenerator.vhd ../savestate_f01_opll_architecture/sim_opll/phasememory.vhd ../savestate_f01_opll_architecture/sim_opll/phasegenerator.vhd ../savestate_f01_opll_architecture/sim_opll/sinetable.vhd ../savestate_f01_opll_architecture/sim_opll/operator.vhd ../savestate_f01_opll_architecture/sim_opll/feedbackmemory.vhd ../savestate_f01_opll_architecture/sim_opll/outputmemory.vhd ../savestate_f01_opll_architecture/sim_opll/lineartable.vhd ../savestate_f01_opll_architecture/sim_opll/outputgenerator.vhd ../savestate_f01_opll_architecture/sim_opll/temporalmixer.vhd ../savestate_f01_opll_architecture/sim_opll/controller.vhd ../savestate_f01_opll_architecture/sim_opll/opll.vhd
vcom -work local_work -2008 local_tb.vhd
vsim -t 1ps local_work.local_tb
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
