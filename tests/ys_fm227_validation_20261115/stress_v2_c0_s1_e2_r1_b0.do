onerror {quit -code 1}
vsim work.stress_tb -gCUT=0 -gSTALL=1 -gEXCLUDE=2 -gROUNDS=1 -gBANK=0
run -all
quit -code 0
