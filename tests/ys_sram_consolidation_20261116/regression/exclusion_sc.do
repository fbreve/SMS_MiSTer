onerror {quit -code 1}
vsim work.exclusion_tb -gSYSTEM_E=0 -gELIGIBLE=0
run -all
quit -code 0
