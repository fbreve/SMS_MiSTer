onerror {quit -code 1}
onbreak {quit -code 1}
vlib recovery_work
vcom -2008 -work recovery_work -quiet ../../rtl/spram.vhd
vlog -sv -work recovery_work -quiet ../../rtl/parts.v ../../rtl/MC8123.v ../../rtl/SEGASYS1_PRGDEC.v decrypt_path.sv recovery_tb.sv
vsim -c -L altera_mf recovery_work.recovery_tb
run -all
quit -code 0
