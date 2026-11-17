onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -gT=80540 f10_replay_work.replay
run -all
quit -code 0
