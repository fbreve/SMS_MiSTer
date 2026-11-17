onerror {quit -code 1}
onbreak {quit -code 1}
vlib replay_work
vlog -work replay_work -sv -quiet paddle_fixture.sv replay.sv
vsim -c replay_work.replay
run -all
quit -code 0
