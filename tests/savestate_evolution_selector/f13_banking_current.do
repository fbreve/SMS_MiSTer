onerror {quit -code 1}
onbreak {quit -code 1}
vlib banking_work
vcom -work banking_work -2008 -quiet mapper_ctrl_sim.vhd ../../simulation/mapper_banking/mapper_baseline.vhd banking_tb.vhd
vsim -c banking_work.tb
run 2 ms
quit -code 0
