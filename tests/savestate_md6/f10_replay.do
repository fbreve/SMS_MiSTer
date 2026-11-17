onerror {quit -code 1}
onbreak {quit -code 1}
vlib f10_replay_work
vlog -work f10_replay_work -sv -quiet ../../rtl/sega_controller.sv replay.sv
vsim -c -gT=64 f10_replay_work.replay
run -all
quit -code 0
