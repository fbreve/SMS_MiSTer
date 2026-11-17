onerror {quit -code 1}
onbreak {quit -code 1}
vlib work
vlog -suppress 2388 -quiet A_jt89_vol.v A_jt89_tone.v A_jt89_noise.v A_jt89_mixer.v A_jt89.v
vcom -2008 -quiet A_controls.vhd A_AudioMix.vhd
vlog -suppress 2388 -quiet B_jt89_vol.v B_jt89_tone.v B_jt89_noise.v B_jt89_mixer.v B_jt89.v
vcom -2008 -quiet B_controls.vhd B_AudioMix.vhd
vlog -suppress 2388 -quiet C_jt89_vol.v C_jt89_tone.v C_jt89_noise.v C_jt89_mixer.v C_jt89.v
vcom -2008 -quiet C_controls.vhd C_AudioMix.vhd
vlog -sv -quiet native_tb.sv
vsim -c -t 1ps -voptargs=+acc work.native_tb
force -deposit /native_tb/Amix/toggle 0 0
force -deposit /native_tb/Bmix/toggle 0 0
force -deposit /native_tb/Cmix/toggle 0 0
run -all
quit -code 0
