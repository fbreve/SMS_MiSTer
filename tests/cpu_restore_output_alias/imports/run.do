onerror {quit -code 1}
onbreak {quit -code 1}
vlib test_work
vcom -work test_work -2008 -quiet ../../../rtl/T80/T80_Reg.vhd ../../../rtl/T80/T80_MCode.vhd ../../../rtl/T80/T80_ALU.vhd T80_sim.vhd T80s_sim.vhd
vlog -work test_work -sv ../../../rtl/opll_snapshot.sv savestates_sim.sv candidate_sim.sv imports_tb.sv
vsim -t 1ps test_work.vdp_tb -g/vdp_tb/dut/TB_FAST=1
set NumericStdNoWarnings 1
run -all
quit -code 0
