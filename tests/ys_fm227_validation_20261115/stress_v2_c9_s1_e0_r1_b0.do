onerror {quit -code 1}
vsim work.stress_tb -gCUT=9 -gSTALL=1 -gEXCLUDE=0 -gROUNDS=1 -gBANK=0
run -all
quit -code 0
