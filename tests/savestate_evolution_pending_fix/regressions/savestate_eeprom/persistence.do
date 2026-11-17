onerror {quit -code 1}
onbreak {quit -code 1}
vlib persistence_work
vlog -work persistence_work -sv -suppress 2244 -quiet savestates_sim.sv persistence_tb.sv
vsim -c -t 1ps persistence_work.persistence_tb
run -all
quit -code 0
