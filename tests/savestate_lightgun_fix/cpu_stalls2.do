onerror {quit -code 1}
onbreak {quit -code 1}
vlib cpu2_work
vcom -work cpu2_work -2008 -quiet ../../rtl/video.vhd ../../rtl/io.vhd ../../rtl/T80/T80_Reg.vhd ../../rtl/T80/T80_MCode.vhd ../../rtl/T80/T80_ALU.vhd T80_sim.vhd T80s_sim.vhd
vlog -work cpu2_work -sv -quiet savestates_sim.sv gun_fixture.sv cpu_tb.sv
vsim -c -t 1ps -gSTALL=2 cpu2_work.cpu_replay
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
