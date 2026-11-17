onerror {quit -code 1}
onbreak {quit -code 1}
vlib component_work
vcom -work component_work -2008 -quiet vdp_cram_reference.vhd vdp_cram_candidate.vhd
vlog -work component_work -sv component_tb.sv
vsim component_work.component_tb
run -all
quit -code 0
