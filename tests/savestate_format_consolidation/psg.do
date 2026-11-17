onerror {quit -code 1}
onbreak {quit -code 1}
vlib psg_work
vlog -work psg_work -suppress 2388 -quiet ../../rtl/jt89/jt89_vol.v ../../rtl/jt89/jt89_tone.v ../../rtl/jt89/jt89_noise.v ../../rtl/jt89/jt89_mixer.v ../../rtl/jt89/jt89.v
vlog -work psg_work -sv -quiet psg_replay_tb.sv
vsim -c -t 1ps psg_work.psg_replay_tb
run -all
quit -code 0

