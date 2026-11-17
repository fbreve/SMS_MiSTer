onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -gPHASES=0 directed_work.replay
run -all
quit -code 0
