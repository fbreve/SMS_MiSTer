onerror {quit -code 1}
onbreak {quit -code 1}
vlib phase_work
vlog -work phase_work -sv phase_tb.sv
vsim -c phase_work.phase_tb
run -all
quit -code 0
