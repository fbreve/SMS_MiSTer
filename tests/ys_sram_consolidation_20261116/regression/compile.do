onerror {quit -code 1}
vlib work
vlog -sv -quiet opll_snapshot.sv baseline_controller.sv candidate_controller.sv controller_adapter.sv transport_tb.sv stress_tb.sv upgrade_tb.sv legacy_mapper_tb.sv exclusion_tb.sv ordering_tb.sv
quit -code 0
