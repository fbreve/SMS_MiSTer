onerror {quit -code 1}
onbreak {quit -code 1}
vlib work
vlog -suppress 2388 -quiet ../../rtl/jt89/jt89_vol.v ../../rtl/jt89/jt89_tone.v ../../rtl/jt89/jt89_noise.v ../../rtl/jt89/jt89_mixer.v ../../rtl/jt89/jt89.v
vlog -sv -quiet psg_replay_tb.sv
vsim -c -t 1ps work.psg_replay_tb
run -all
quit -code 0
