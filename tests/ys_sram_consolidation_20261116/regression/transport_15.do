onerror {quit -code 1}
vsim work.transport_tb -gCANDIDATE=2 -gFORMAT_CASE=0 -gMAP_MODE=1 -gELIGIBLE=0 -gCLASS=2
run -all
quit -code 0
