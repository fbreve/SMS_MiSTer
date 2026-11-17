onerror {quit -code 1 -force}
onbreak {quit -code 1 -force}
vlib vendor_work
vlog -work vendor_work -sv mlab_collision_tb.sv
vsim -t 1ps -L cyclonev_ver -L altera_lnsim_ver vendor_work.mlab_collision_tb
run -all
quit -code 0 -force
