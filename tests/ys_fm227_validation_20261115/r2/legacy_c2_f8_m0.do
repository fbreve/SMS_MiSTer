onerror {quit -code 1}
vsim work.legacy_mapper_tb -gCANDIDATE=2 -gFORMAT_CASE=8 -gMAP_MODE=0
run -all
quit -code 0
