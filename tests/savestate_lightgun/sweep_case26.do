onerror {quit -code 1}
onbreak {quit -code 1}
vlib sweep2_work
vcom -work sweep2_work -2008 -quiet ../../rtl/video.vhd
vlog -work sweep2_work -sv -quiet gun_fixture.sv sweep.sv
vsim -c -gPAL=1 -gBORDER=0 -gMODE=2 -gPX=0 -gPY=128 sweep2_work.sweep
set StdArithNoWarnings 1
run -all
quit -code 0
