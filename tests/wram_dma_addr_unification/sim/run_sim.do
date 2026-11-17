vlib work
vlog -sv savestates_baseline.sv
vlog -sv savestates_candidate.sv
vlog -sv wram_verification_tb.sv
vsim -c -do "run -all; quit -code 0" work.wram_verification_tb

