onerror {quit -code 1}
onbreak {quit -code 1}
vlib ordinary_work
vlog -work ordinary_work -sv -quiet paddle_fixture.sv ordinary_fixture.sv ordinary.sv
vsim -c ordinary_work.ordinary
run -all
quit -code 0
