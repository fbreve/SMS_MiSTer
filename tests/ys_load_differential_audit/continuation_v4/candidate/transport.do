onerror {quit -code 1}
vsim -c work.transport_tb -gCANDIDATE=2
run -all
quit -code 0
