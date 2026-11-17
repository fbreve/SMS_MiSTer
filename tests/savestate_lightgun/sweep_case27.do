onerror {quit -code 1}
onbreak {quit -code 1}
vlib sweep3_work
vcom -work sweep3_work -2008 -quiet ../../rtl/video.vhd
vlog -work sweep3_work -sv -quiet gun_fixture.sv sweep.sv
vsim -c -gPAL=0 -gBORDER=1 -gMODE=0 -gPX=255 -gPY=252 sweep3_work.sweep
set StdArithNoWarnings 1
run -all
quit -code 0
