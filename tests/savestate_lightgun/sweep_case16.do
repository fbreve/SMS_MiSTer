onerror {quit -code 1}
onbreak {quit -code 1}
vlib sweep4_work
vcom -work sweep4_work -2008 -quiet ../../rtl/video.vhd
vlog -work sweep4_work -sv -quiet gun_fixture.sv sweep.sv
vsim -c -gPAL=0 -gBORDER=0 -gMODE=2 -gPX=255 -gPY=255 sweep4_work.sweep
set StdArithNoWarnings 1
run -all
quit -code 0
