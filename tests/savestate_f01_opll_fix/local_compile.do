onerror {quit -code 1}
vlib local_work
vcom -work local_work -2008 sim_opll/vm2413.vhd sim_opll/slotcounter.vhd sim_opll/voicerom.vhd sim_opll/voicememory.vhd sim_opll/registermemory.vhd sim_opll/attacktable.vhd sim_opll/envelopememory.vhd sim_opll/envelopegenerator.vhd sim_opll/phasememory.vhd sim_opll/phasegenerator.vhd sim_opll/sinetable.vhd sim_opll/operator.vhd sim_opll/feedbackmemory.vhd sim_opll/outputmemory.vhd sim_opll/lineartable.vhd sim_opll/outputgenerator.vhd sim_opll/temporalmixer.vhd sim_opll/controller.vhd sim_opll/opll.vhd
quit -code 0
