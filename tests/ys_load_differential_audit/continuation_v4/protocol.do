onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps work.controller_tb -gCANDIDATE=$env(YS_CANDIDATE) -gFORMAT_CASE=$env(YS_FORMAT_CASE)
run -all
quit -code 0
