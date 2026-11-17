onerror {quit -code 1}
vsim work.legacy_mapper_tb -gCANDIDATE=0 -gFORMAT_CASE=0 -gMAP_MODE=2
run -all
quit -code 0
