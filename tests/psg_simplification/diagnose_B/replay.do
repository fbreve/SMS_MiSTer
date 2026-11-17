onerror {quit -code 1}
onbreak {quit -code 1}
vlib work
vlog -suppress 2388 -quiet jt89_vol.v jt89_tone.v jt89_noise.v jt89_mixer.v jt89.v
vlog -sv -quiet psg_replay_tb.sv
vsim -c -t 1ps work.psg_replay_tb
run -all
quit -code 0
