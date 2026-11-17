onerror {quit -code 1}
vlog -sv -quiet exclusion_tb.sv
vsim -c work.exclusion_tb -gSYSTEM_E=$env(YS_SYSTEM_E) -gELIGIBLE=$env(YS_ELIGIBLE)
run -all
quit -code 0
