onerror {quit -code 1}
vsim work.transport_tb -gCANDIDATE=2 -gFORMAT_CASE=7 -gMAP_MODE=0 -gELIGIBLE=0 -gCLASS=2
run -all
quit -code 0
