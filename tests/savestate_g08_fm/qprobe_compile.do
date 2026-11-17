onerror {quit -code 1}
onbreak {quit -code 1}
vlib qprobe_work
vcom -work qprobe_work -2008 -quiet sim_opll/vm2413.vhd sim_opll/slotcounter.vhd sim_opll/voicerom.vhd sim_opll/voicememory.vhd sim_opll/registermemory.vhd sim_opll/attacktable.vhd sim_opll/envelopememory.vhd sim_opll/envelopegenerator.vhd sim_opll/phasememory.vhd sim_opll/phasegenerator.vhd sim_opll/sinetable.vhd sim_opll/operator.vhd sim_opll/feedbackmemory.vhd sim_opll/outputmemory.vhd sim_opll/lineartable.vhd sim_opll/outputgenerator.vhd sim_opll/temporalmixer.vhd sim_opll/controller.vhd sim_opll/opll.vhd
vcom -work qprobe_work -2008 -quiet candidate/rtl/AudioMix.vhd ../../rtl/video.vhd ../../rtl/T80/T80_Reg.vhd ../../rtl/T80/T80_MCode.vhd ../../rtl/T80/T80_ALU.vhd T80_sim.vhd T80s_sim.vhd
vlog -work qprobe_work -suppress 2388 -quiet ../../rtl/jt89/jt89_vol.v ../../rtl/jt89/jt89_tone.v ../../rtl/jt89/jt89_noise.v ../../rtl/jt89/jt89_mixer.v ../../rtl/jt89/jt89.v
vlog -work qprobe_work -sv -quiet ../../rtl/opll_snapshot.sv candidate_known_controller.sv pause_fixture.sv qprobe_tb.sv
quit -code 0
