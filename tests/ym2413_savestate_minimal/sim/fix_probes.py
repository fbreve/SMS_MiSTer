with open('tests/ym2413_savestate_minimal/sim/tb_ym2413_diff.sv', 'r', encoding='latin-1') as f:
    c = f.read()

target = '''    // Probes for internal envelope and phase of Channel 0 Slot 1 (carrier)
    wire [1:0] dut_egstate_c0 = dut_opll.eg.u_envelope_memory.egdata_set[1].state;
    wire [22:0] dut_egphase_c0 = dut_opll.eg.u_envelope_memory.egdata_set[1].phase;
    wire [1:0] ref_egstate_c0 = ref_opll.eg.u_envelope_memory.egdata_set[1].state;
    wire [22:0] ref_egphase_c0 = ref_opll.eg.u_envelope_memory.egdata_set[1].phase;

    wire [17:0] dut_phase_c0 = dut_opll.pg.MEM.phase_array[1];
    wire [17:0] ref_phase_c0 = ref_opll.pg.MEM.phase_array[1];'''

replacement = '''    // Probes for internal envelope vector and phase of Channel 0 Slot 1 (carrier)
    wire [24:0] dut_egvec_c0 = dut_opll.eg.u_envelope_memory.egdata_set[1];
    wire [24:0] ref_egvec_c0 = ref_opll.eg.u_envelope_memory.egdata_set[1];

    wire [17:0] dut_phase_c0 = dut_opll.pg.MEM.phase_array[1];
    wire [17:0] ref_phase_c0 = ref_opll.pg.MEM.phase_array[1];'''

c = c.replace(target, replacement)

target_print = '''        $display("[PROBE CICLO 0] DUT egstate=%b egphase=%h phase=%h | REF egstate=%b egphase=%h phase=%h",
                 dut_egstate_c0, dut_egphase_c0, dut_phase_c0, ref_egstate_c0, ref_egphase_c0, ref_phase_c0);'''

repl_print = '''        $display("[PROBE CICLO 0] DUT egvec=%h phase=%h | REF egvec=%h phase=%h",
                 dut_egvec_c0, dut_phase_c0, ref_egvec_c0, ref_phase_c0);'''

c = c.replace(target_print, repl_print)

with open('tests/ym2413_savestate_minimal/sim/tb_ym2413_diff.sv', 'w', encoding='latin-1') as f:
    f.write(c)
print('Fixed probe signals.')

