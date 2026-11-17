onerror {quit -code 1}
vsim work.upgrade_tb -gCUT=0 -gPREVIOUS_FM=1
run -all
quit -code 0
