onerror {quit -code 1}
onbreak {quit -code 1}
vlib directed_work
vlog -work directed_work -sv -quiet paddle_fixture.sv replay.sv
vsim -c -gPHASES=0 directed_work.replay
run -all
quit -code 0
