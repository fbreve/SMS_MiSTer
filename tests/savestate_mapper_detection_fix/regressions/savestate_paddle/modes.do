onerror {quit -code 1}
onbreak {quit -code 1}
vlib modes_work
vlog -work modes_work -sv -quiet paddle_fixture.sv replay.sv
vsim -c -gPHASES=2 modes_work.replay
run -all
quit -code 0
