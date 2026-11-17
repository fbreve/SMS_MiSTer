onerror {quit -code 1}
vcom -2008 -quiet vdp_probe.vhd
vlog -sv -quiet ys_warm_tb.sv
quit -code 0
