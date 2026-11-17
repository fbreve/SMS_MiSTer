onerror {quit -code 1}
vmap -c
vlib reference_work
vmap reference_work reference_work
vcom -2008 -quiet -work reference_work ../native_reference/vm2413.vhd ../native_reference/slotcounter.vhd ../native_reference/voicerom.vhd ../native_reference/voicememory.vhd ../native_reference/registermemory.vhd ../native_reference/attacktable.vhd ../native_reference/envelopememory.vhd ../native_reference/envelopegenerator.vhd ../native_reference/phasememory.vhd ../native_reference/phasegenerator.vhd ../native_reference/sinetable.vhd ../native_reference/operator.vhd ../native_reference/feedbackmemory.vhd ../native_reference/outputmemory.vhd ../native_reference/lineartable.vhd ../native_reference/outputgenerator.vhd ../native_reference/temporalmixer.vhd ../native_reference/controller.vhd ../native_reference/opll.vhd ../reference_wrapper.vhd
vlib candidate_work
vmap candidate_work candidate_work
vcom -2008 -quiet -work candidate_work ../native_candidate/vm2413.vhd ../native_candidate/slotcounter.vhd ../native_candidate/voicerom.vhd ../native_candidate/voicememory.vhd ../native_candidate/registermemory.vhd ../native_candidate/attacktable.vhd ../native_candidate/envelopememory.vhd ../native_candidate/envelopegenerator.vhd ../native_candidate/phasememory.vhd ../native_candidate/phasegenerator.vhd ../native_candidate/sinetable.vhd ../native_candidate/operator.vhd ../native_candidate/feedbackmemory.vhd ../native_candidate/outputmemory.vhd ../native_candidate/lineartable.vhd ../native_candidate/outputgenerator.vhd ../native_candidate/temporalmixer.vhd ../native_candidate/controller.vhd ../native_candidate/opll.vhd ../candidate_wrapper.vhd
vcom -2008 -quiet -work candidate_work ../../../rtl/video.vhd ../combined_tb.vhd
quit -code 0
