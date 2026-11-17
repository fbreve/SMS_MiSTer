onerror {quit -code 1}
onbreak {quit -code 1}
vlib raw_work
vlog -work raw_work -suppress 2388 -quiet ../../../rtl/jt89/jt89_vol.v ../../../rtl/jt89/jt89_tone.v ../../../rtl/jt89/jt89_noise.v ../../../rtl/jt89/jt89_mixer.v ../../../rtl/jt89/jt89.v psg_replay_tb.sv
vsim -c raw_work.psg_replay_tb
run -all
quit -code 0
