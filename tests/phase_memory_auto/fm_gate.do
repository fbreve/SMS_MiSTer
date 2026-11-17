onerror {quit -code 1}
onbreak {quit -code 1}
vlib mapped_work
set sources {vm2413 slotcounter voicerom voicememory registermemory attacktable envelopememory envelopegenerator phasememory phasegenerator sinetable operator feedbackmemory outputmemory lineartable outputgenerator temporalmixer controller opll}
foreach source $sources {
 if {$source eq "phasememory"} {vcom -93 -quiet -work mapped_work mapped_phasememory.vhd} else {vcom -93 -quiet -work mapped_work candidate_sim/${source}.vhd}
}
vcom -2008 -quiet -work test_work fm_gate_tb.vhd
vsim -c -t 1ps -L gate_work -L cyclonev_ver -L altera_ver -L altera_mf_ver -L altera_lnsim_ver -L sgate_ver test_work.fm_gate_tb
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
