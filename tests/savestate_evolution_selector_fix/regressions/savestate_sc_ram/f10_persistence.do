onerror {quit -code 1}
onbreak {quit -code 1}
vlib f10_persistence_work
vlog -work f10_persistence_work -sv -suppress 2244 -quiet f10_savestates_sim.sv f10_persistence_tb.sv
vsim -c -t 1ps f10_persistence_work.persistence_tb
run -all
quit -code 0
