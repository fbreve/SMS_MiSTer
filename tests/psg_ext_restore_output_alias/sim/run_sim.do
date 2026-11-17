vlib work
vlog -sv controller_baseline.sv
vlog -sv controller_candidate.sv
vlog -sv psg_ext_verification_tb.sv
vsim -c -do "run -all; quit -f" work.psg_ext_verification_tb

