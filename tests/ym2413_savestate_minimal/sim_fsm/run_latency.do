onerror {quit -code 1}
onbreak {quit -code 1}

vlib work

vcom -work work -93 -quiet ../../../rtl/VM2413/vm2413.vhd
vcom -work work -93 -quiet ../../../rtl/VM2413/slotcounter.vhd
vcom -work work -93 -quiet sim_vhd/voicerom.vhd
vcom -work work -93 -quiet ../../../rtl/VM2413/voicememory.vhd
vcom -work work -93 -quiet ../../../rtl/VM2413/registermemory.vhd
vcom -work work -93 -quiet ../../../rtl/VM2413/attacktable.vhd
vcom -work work -93 -quiet ../../../rtl/VM2413/envelopememory.vhd
vcom -work work -93 -quiet ../../../rtl/VM2413/envelopegenerator.vhd
vcom -work work -93 -quiet ../../../rtl/VM2413/phasememory.vhd
vcom -work work -93 -quiet ../../../rtl/VM2413/phasegenerator.vhd
vcom -work work -93 -quiet ../../../rtl/VM2413/sinetable.vhd
vcom -work work -93 -quiet ../../../rtl/VM2413/operator.vhd
vcom -work work -93 -quiet ../../../rtl/VM2413/feedbackmemory.vhd
vcom -work work -93 -quiet ../../../rtl/VM2413/outputmemory.vhd
vcom -work work -93 -quiet ../../../rtl/VM2413/lineartable.vhd
vcom -work work -93 -quiet ../../../rtl/VM2413/outputgenerator.vhd
vcom -work work -93 -quiet ../../../rtl/VM2413/temporalmixer.vhd
vcom -work work -93 -quiet ../../../rtl/VM2413/controller.vhd
vcom -work work -93 -quiet ../../../rtl/VM2413/opll.vhd

vlog -work work -sv -quiet tb_ym2413_latency_audit.sv

vsim -c -do "run -all; quit -f" work.tb_ym2413_latency_audit

