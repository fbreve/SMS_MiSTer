onerror {quit -code 1}
onbreak {quit -code 1}
vlib sweep0_work
vcom -work sweep0_work -2008 -quiet ../../rtl/video.vhd
vlog -work sweep0_work -sv -quiet gun_fixture.sv sweep.sv
vsim -c -gPAL=1 -gBORDER=0 -gMODE=0 -gPX=255 -gPY=252 sweep0_work.sweep
set StdArithNoWarnings 1
run -all
quit -code 0
