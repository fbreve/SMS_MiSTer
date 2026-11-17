onerror {quit -code 1}
onbreak {quit -code 1}
vlib candidate_work
vlib reference_work
vlib test_work
vmap candidate_work candidate_work
vmap reference_work reference_work
vmap test_work test_work
vcom -2008 -quiet -work candidate_work candidate/vm2413.vhd candidate/slotcounter.vhd candidate/voicerom.vhd candidate/voicememory.vhd candidate/registermemory.vhd candidate/attacktable.vhd candidate/envelopememory.vhd candidate/envelopegenerator.vhd candidate/phasememory.vhd candidate/phasegenerator.vhd candidate/sinetable.vhd candidate/operator.vhd candidate/feedbackmemory.vhd candidate/outputmemory.vhd candidate/lineartable.vhd candidate/outputgenerator.vhd candidate/temporalmixer.vhd candidate/controller.vhd candidate/opll.vhd candidate_wrapper.vhd
vcom -2008 -quiet -work reference_work reference/vm2413.vhd reference/slotcounter.vhd reference/voicerom.vhd reference/voicememory.vhd reference/registermemory.vhd reference/attacktable.vhd reference/envelopememory.vhd reference/envelopegenerator.vhd reference/phasememory.vhd reference/phasegenerator.vhd reference/sinetable.vhd reference/operator.vhd reference/feedbackmemory.vhd reference/outputmemory.vhd reference/lineartable.vhd reference/outputgenerator.vhd reference/temporalmixer.vhd reference/controller.vhd reference/opll.vhd reference_wrapper.vhd
vlog -sv -quiet -work test_work ../../rtl/opll_snapshot.sv savestates_sim.sv master_savestates.sv tb.sv
quit -code 0
