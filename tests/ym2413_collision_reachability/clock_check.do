onerror {quit -code 1 -force}
onbreak {quit -code 1 -force}
vlog -sv -work validator_work clock_check.sv
vsim validator_work.clock_check
run -all
quit -code 0 -force
