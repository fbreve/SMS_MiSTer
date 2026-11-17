onerror {quit -code 1}
onbreak {quit -code 1}
vlib miter_work
vlog -work miter_work -sv -quiet ../../../rtl/opll_snapshot.sv golden.sv candidate.sv miter.sv
vsim -t 1ps miter_work.vdp_tb
run 10 us
echo "FIRST_STATE [examine /vdp_tb/dut/state] clocks [examine /vdp_tb/cycles]"
run -all
quit -code 0
