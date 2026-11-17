if {![info exists env(F14_STALL)]} {set env(F14_STALL) 0}
onerror {quit -code 1}
onbreak {quit -code 1}
vlib pending_direct_work
vcom -work pending_direct_work -2008 -quiet evolution_observed.vhd f13_mapper_ctrl_sim.vhd ../../rtl/evolution_rom_address.vhd
vlog -work pending_direct_work -sv -quiet savestates_sim.sv evolution_banked_machine.sv directed_tb.sv
vsim -c -t 1ps -voptargs=+acc pending_direct_work.evolution_fixed_tb -gCASE=$env(F14_CASE) -gSTALL=$env(F14_STALL)
set NumericStdNoWarnings 1
run -all
quit -code 0
