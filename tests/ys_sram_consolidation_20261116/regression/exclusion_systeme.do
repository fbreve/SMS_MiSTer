onerror {quit -code 1}
vsim work.exclusion_tb -gSYSTEM_E=1 -gELIGIBLE=1
run -all
quit -code 0
