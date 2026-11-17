with open('tests/ym2413_savestate_minimal/sim/tb_ym2413_diff.sv', 'r', encoding='latin-1') as f:
    lines = f.readlines()

new_lines = []
for line in lines:
    new_lines.append(line)
    if '[CHECK 1] Validando Estado' in line:
        new_lines.append('''
        #100;
        $display("[PROBE CICLO 0] DUT egvec=%h phase=%h | REF egvec=%h phase=%h",
                 dut_egvec_c0, dut_phase_c0, ref_egvec_c0, ref_phase_c0);
''')
    elif '[METRICA FRAME 1]' in line:
        new_lines.append('''
        $display("[PROBE FRAME 1] DUT egvec=%h phase=%h | REF egvec=%h phase=%h",
                 dut_egvec_c0, dut_phase_c0, ref_egvec_c0, ref_phase_c0);
''')
    elif '[METRICA FRAME 2]' in line:
        new_lines.append('''
        $display("[PROBE FRAME 2] DUT egvec=%h phase=%h | REF egvec=%h phase=%h",
                 dut_egvec_c0, dut_phase_c0, ref_egvec_c0, ref_phase_c0);
''')

with open('tests/ym2413_savestate_minimal/sim/tb_ym2413_diff.sv', 'w', encoding='latin-1') as f:
    f.writelines(new_lines)
print('Probes inserted cleanly')

