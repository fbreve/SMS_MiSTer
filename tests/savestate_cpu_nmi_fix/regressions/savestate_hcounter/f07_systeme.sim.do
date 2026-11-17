onerror {quit -code 1}
onbreak {quit -code 1}
vsim -c -t 1ps -L altera_mf f11_integration_work.integration_tb -g/integration_tb/vdp1/vdp_vram_inst/init_file=UNUSED -g/integration_tb/vdp2/vdp_vram_inst/init_file=UNUSED
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
