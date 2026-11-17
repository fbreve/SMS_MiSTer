onerror {quit -code 1}
onbreak {quit -code 1}
vlib before_work
vlog -work before_work -sv -quiet before_fixture.sv before.sv
vsim -c before_work.before_replay
run -all
quit -code 0
