onerror {quit -code 1}
onbreak {quit -code 1}
vlib unit_work
vlog -work unit_work -sv -suppress 2244 -quiet sdram.v pin_model.sv controller_tb.sv
quit -code 0
