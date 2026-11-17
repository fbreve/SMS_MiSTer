onerror {quit -code 1}
onbreak {quit -code 1}
vlib direct_work
vlog -work direct_work -sv -quiet direct_gun.sv baseline_gun.sv direct_tb.sv
vsim -c -t 1ps direct_work.direct_tb
run -all
quit -code 0
