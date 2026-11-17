onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c unit_work.controller_tb -gPERIOD=15 -gTAC=7
run -all
quit -code 0
