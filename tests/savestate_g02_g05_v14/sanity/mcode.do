onerror {quit -code 1}
onbreak {resume}
vlib work
vcom -2008 -quiet ../../../rtl/T80/T80_MCode.vhd mcode_bound.vhd
vsim -c work.mcode_bound
run -all
quit -code 0
