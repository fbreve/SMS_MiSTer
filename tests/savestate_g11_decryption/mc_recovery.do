onerror {quit -code 1}
onbreak {quit -code 1}
vlog -sv -work recovery_work -quiet mc_recovery_tb.sv
vsim -c -L altera_mf recovery_work.mc_recovery_tb
run -all
quit -code 0
