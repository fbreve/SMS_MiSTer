onerror {quit -code 1}
onbreak {quit -code 1}
vlib lut_work
vlog -work lut_work -sv -quiet ../../rtl/MC8123.v lut_tb.sv
vsim -c lut_work.lut_tb
run -all
quit -code 0
