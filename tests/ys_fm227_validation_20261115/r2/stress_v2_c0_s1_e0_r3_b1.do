onerror {quit -code 1}
vsim work.stress_tb -gCUT=0 -gSTALL=1 -gEXCLUDE=0 -gROUNDS=3 -gBANK=1
run -all
quit -code 0
