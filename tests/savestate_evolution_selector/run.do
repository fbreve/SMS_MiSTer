onerror {quit -code 1}
onbreak {quit -code 1}
vlib evolution_work
vcom -work evolution_work -2008 -quiet ../../rtl/evolution_mapper.vhd ../../rtl/evolution_rom_address.vhd
vlog -work evolution_work -sv -quiet savestates_sim.sv evolution_machine.sv evolution_tb.sv
vsim -c -t 1ps -voptargs=+acc evolution_work.evolution_tb -gCASE=$env(F14_CASE)
set NumericStdNoWarnings 1
run -all
quit -code 0
