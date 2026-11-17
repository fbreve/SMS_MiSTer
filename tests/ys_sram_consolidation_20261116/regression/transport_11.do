onerror {quit -code 1}
vsim work.transport_tb -gCANDIDATE=3 -gFORMAT_CASE=0 -gMAP_MODE=2 -gELIGIBLE=1 -gCLASS=2
run -all
quit -code 0
