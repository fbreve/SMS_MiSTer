onerror {quit -code 1 -force}
onbreak {quit -code 1 -force}
vlib validator_work
vlog -sv -work validator_work validate.sv
vsim validator_work.validate
run -all
quit -code 0 -force
