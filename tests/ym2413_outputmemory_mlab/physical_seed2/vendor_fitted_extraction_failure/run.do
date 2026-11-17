onerror {quit -code 1 -force}
onbreak {quit -code 1 -force}
vlib mapped_work
vlog -work mapped_work mapped_output_cut.v
vlog -sv -work mapped_work mapped_tb.sv
vsim -t 1ps -L cyclonev_ver -L altera_ver -L altera_lnsim_ver mapped_work.mapped_tb
run -all
quit -code 0 -force
