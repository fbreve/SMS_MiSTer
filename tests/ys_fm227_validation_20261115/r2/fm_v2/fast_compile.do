onerror {quit -code 1}
vlib fast_work
vmap fast_work fast_work
vlog -sv -quiet -work fast_work opll_snapshot.sv savestates_fast.sv tb.sv
quit -code 0
