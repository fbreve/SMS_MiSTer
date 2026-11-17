onerror {quit -code 1}
onbreak {resume}
vsim -c -t 1ps work.gg_tb -gexpect_fixed=$env(GG_FIXED)
run -all
quit -code 0
