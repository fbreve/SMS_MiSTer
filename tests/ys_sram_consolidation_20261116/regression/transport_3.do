onerror {quit -code 1}
vsim work.transport_tb -gCANDIDATE=1 -gFORMAT_CASE=0 -gMAP_MODE=0 -gELIGIBLE=1 -gCLASS=2
run -all
quit -code 0
