onerror {quit -code 1}
onbreak {quit -code 1}
vlib work
vlog -sv controller_baseline.sv controller_candidate.sv evolution_verification_tb.sv
vsim -c -do "run -all; quit -code 0" work.evolution_verification_tb
quit -code 0

