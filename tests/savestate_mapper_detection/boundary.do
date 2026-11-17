onerror {quit -code 1}
onbreak {quit -code 1}
vlib boundary_work
vcom -work boundary_work -2008 -quiet ../../rtl/mapper_detect.vhd mapper_ctrl_sim.vhd ../../rtl/memory_decode.vhd
vlog -work boundary_work -sv -quiet savestates_sim.sv machine.sv boundary_tb.sv
vsim -c -t 1ps -voptargs=+acc boundary_work.boundary_tb
set NumericStdNoWarnings 1
when {/boundary_tb/ss_freeze == 1} {echo "HISTORY ticks=[examine -radix unsigned /boundary_tb/loaded_machine/mapper_detect_inst/mapper_detect_ticks] bank=[examine /boundary_tb/loaded_machine/mapper_detect_inst/bank_write_seen] sega=[examine /boundary_tb/loaded_machine/mapper_detect_inst/sega_mapper_write_seen] wonderkid_count=[examine -radix unsigned /boundary_tb/loaded_machine/mapper_detect_inst/wonderkid_write_count]"}
run -all
quit -code 0
