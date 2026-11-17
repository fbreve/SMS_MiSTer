onerror {quit -code 1}
vsim work.transport_tb -gCANDIDATE=2 -gFORMAT_CASE=8 -gMAP_MODE=1 -gELIGIBLE=1 -gCLASS=2
run -all
quit -code 0
