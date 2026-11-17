onerror {quit -code 1}
onbreak {quit -code 1}
set sources {vm2413 slotcounter voicerom voicememory registermemory attacktable envelopememory envelopegenerator phasememory phasegenerator sinetable operator feedbackmemory outputmemory lineartable outputgenerator temporalmixer controller opll}
foreach variant {baseline candidate} {
 foreach source $sources {vcom -93 -quiet -work ${variant}_work ${variant}_sim/${source}.vhd}
}
vcom -2008 -quiet -work test_work fm_tb.vhd
vsim -c -t 1ps test_work.fm_tb
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
