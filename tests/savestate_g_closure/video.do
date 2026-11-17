onerror {quit -code 1}
onbreak {quit -code 1}
vlib work
vcom -2008 ../../rtl/video.vhd
vcom -2008 video_boundary_tb.vhd
vsim -c work.video_boundary_tb
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
