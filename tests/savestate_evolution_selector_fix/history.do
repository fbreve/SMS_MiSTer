onerror {quit -code 1}
onbreak {quit -code 1}
vlib history_work
vcom -work history_work -2008 -quiet ../../rtl/evolution_mapper.vhd ../../rtl/evolution_rom_address.vhd
vlog -work history_work -sv -quiet evolution_machine.sv history_tb.sv
vsim -c -t 1ps history_work.history_matrix_tb
run -all
quit -code 0
