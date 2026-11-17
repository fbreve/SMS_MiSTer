onerror {quit -code 1}
vsim work.legacy_mapper_tb -gCANDIDATE=2 -gFORMAT_CASE=0 -gMAP_MODE=6
run -all
quit -code 0
