onerror {quit -code 1}
vsim -c work.transport_tb -gCANDIDATE=3 -gFORMAT_CASE=8 -gMAP_MODE=2
run -all
quit -code 0
