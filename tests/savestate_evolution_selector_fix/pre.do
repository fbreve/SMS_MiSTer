onerror {quit -code 1}
onbreak {quit -code 1}
vlib pre_work
vcom -work pre_work -2008 -quiet baseline/evolution_mapper.vhd baseline/evolution_rom_address.vhd
vlog -work pre_work -sv -quiet baseline/savestates.sv baseline/evolution_machine.sv baseline/evolution_tb.sv
vsim -c -t 1ps -voptargs=+acc pre_work.evolution_tb -gCASE=$env(F14_CASE)
set NumericStdNoWarnings 1
run -all
quit -code 0
