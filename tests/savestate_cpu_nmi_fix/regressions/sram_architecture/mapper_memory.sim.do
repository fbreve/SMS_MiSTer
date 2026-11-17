onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps -L altera_mf work.characterization
run -all
quit -code 0
