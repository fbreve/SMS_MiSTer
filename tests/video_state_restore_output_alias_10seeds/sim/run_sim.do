vlib work
vlog -sv savestates_baseline.sv
vlog -sv savestates_candidate.sv
vlog -sv video_state_verification_tb.sv
vsim -c -do "run -all; quit -f" work.video_state_verification_tb

