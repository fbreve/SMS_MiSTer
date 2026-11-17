with open('tests/ym2413_savestate_minimal/sim_fsm/tb_ym2413_defects_repro.sv', 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
skip = False
for i, line in enumerate(lines):
    if '// Testar se ST_UNFREEZE_SETTLE aguarda fm_initialized' in line:
        new_lines.append('        // Testar se ST_FM_LEGACY_WAIT aguarda fm_initialized sob bypass de freeze\n')
        new_lines.append('        $display("   Verificando ST_FM_LEGACY_WAIT: aguardando fm_initialized...");\n')
        new_lines.append('        force dut_savestates.state = 7\'d40; // ST_ERROR\n')
        new_lines.append('        tick;\n')
        new_lines.append('        release dut_savestates.state;\n')
        new_lines.append('        wait(dut_savestates.state == 7\'d85); // ST_FM_LEGACY_WAIT\n')
        new_lines.append('        $display("   Entrou em ST_FM_LEGACY_WAIT: ss_freeze=%0b, fm_initialization_run=%0b", ss_freeze, fm_initialization_run);\n')
        new_lines.append('        wait(dut_savestates.state == 7\'d63); // ST_UNFREEZE_SETTLE\n')
        new_lines.append('        $display("[FIX VERIFIED D5] Transicionou para ST_UNFREEZE_SETTLE somente apos fm_initialized=%0b!", fm_initialized);\n')
        new_lines.append('        wait(!ss_freeze);\n')
        new_lines.append('        $display("   Descongelou em ST_IDLE com sucesso.");\n')
        skip = True
        continue
    if skip:
        if 'Descongelou em ST_IDLE.' in line:
            skip = False
        continue
    new_lines.append(line)

with open('tests/ym2413_savestate_minimal/sim_fsm/tb_ym2413_defects_repro.sv', 'w', encoding='utf-8') as f:
    f.writelines(new_lines)
print('Updated D5 test in tb_ym2413_defects_repro.sv')

