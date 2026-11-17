onerror {quit -code 1}
onbreak {quit -code 1}
vlib probe_work
vcom -work probe_work -2008 -quiet ../../rtl/video.vhd
vlog -work probe_work -sv -quiet gun_fixture.sv probe.sv
vsim -c probe_work.probe
set StdArithNoWarnings 1
run -all
quit -code 0
