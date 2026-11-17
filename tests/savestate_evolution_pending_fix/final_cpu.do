onerror {quit -code 1}
onbreak {quit -code 1}
vlib final_cpu_work
vcom -work final_cpu_work -2008 -quiet ../../rtl/video.vhd evolution_observed.vhd ../../rtl/evolution_rom_address.vhd ../../rtl/T80/T80_Reg.vhd ../../rtl/T80/T80_MCode.vhd ../../rtl/T80/T80_ALU.vhd T80_sim.vhd T80s_sim.vhd
vlog -work final_cpu_work -sv -quiet savestates_sim.sv evolution_machine.sv cpu_tb.sv
vsim -c -t 1ps -voptargs=+acc final_cpu_work.cpu_tb -gOFFSET=$env(F15_OFFSET)
set NumericStdNoWarnings 1
run -all
quit -code 0

