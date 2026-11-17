if {![info exists env(F14_STALL)]} {set env(F14_STALL) 0}
onerror {quit -code 1}
onbreak {quit -code 1}
vlib format_work
vcom -work format_work -2008 -quiet ../../rtl/evolution_mapper.vhd ../../rtl/evolution_rom_address.vhd
vlog -work format_work -sv -quiet savestates_sim.sv evolution_machine.sv format_tb.sv
vsim -c -t 1ps -voptargs=+acc format_work.format_tb -gSTALL=$env(F14_STALL)
set NumericStdNoWarnings 1
run -all
quit -code 0
