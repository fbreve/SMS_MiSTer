with open('tests/ym2413_savestate_minimal/sim/tb_ym2413_diff.sv', 'r', encoding='latin-1') as f:
    c = f.read()

target = 'initial begin'
probe_signals = '''
    // Probes for internal envelope and phase of Channel 0 Slot 1 (carrier)
    wire [1:0] dut_egstate_c0 = dut_opll.eg.u_envelope_memory.egdata_set[1].state;
    wire [22:0] dut_egphase_c0 = dut_opll.eg.u_envelope_memory.egdata_set[1].phase;
    wire [1:0] ref_egstate_c0 = ref_opll.eg.u_envelope_memory.egdata_set[1].state;
    wire [22:0] ref_egphase_c0 = ref_opll.eg.u_envelope_memory.egdata_set[1].phase;

    wire [17:0] dut_phase_c0 = dut_opll.pg.MEM.phase_array[1];
    wire [17:0] ref_phase_c0 = ref_opll.pg.MEM.phase_array[1];

initial begin
'''
c = c.replace(target, probe_signals, 1)

target_check = 'Validando Estado Lógico Imediato'
addition = '''Validando Estado Lógico Imediato
        #100;
        $display("[PROBE CICLO 0] DUT egstate=%b egphase=%h phase=%h | REF egstate=%b egphase=%h phase=%h",
                 dut_egstate_c0, dut_egphase_c0, dut_phase_c0, ref_egstate_c0, ref_egphase_c0, ref_phase_c0);
'''
c = c.replace(target_check, addition)

with open('tests/ym2413_savestate_minimal/sim/tb_ym2413_diff.sv', 'w', encoding='latin-1') as f:
    f.write(c)
print('Probes added successfully.')

