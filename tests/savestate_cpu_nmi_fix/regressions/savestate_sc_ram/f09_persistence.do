onerror {quit -code 1}
onbreak {quit -code 1}
vlib f09_persistence_work
vlog -work persistence_work -sv -suppress 2244 -quiet f09_savestates_sim.sv f09_persistence_tb.sv
vsim -c -t 1ps persistence_work.persistence_tb
run -all
quit -code 0
