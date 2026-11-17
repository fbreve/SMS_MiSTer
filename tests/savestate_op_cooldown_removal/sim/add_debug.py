with open('tests/savestate_op_cooldown_removal/sim/cooldown_verification_tb.sv', 'r') as f:
    text = f.read()

old_block = '''        $display("Candidato abortou para ST_IDLE e liberou freeze perfeitamente. Testando ciclo subsequente...");
        // Executa novo SAVE e LOAD normal no candidato para garantir integridade apos aborto
        init_wram(8192, 8'h42);
        ss_save = 1; tick; ss_save = 0;
        wait(ss_freeze_b);
        wait(!ss_freeze_b);
        for (integer k = 0; k < 8192; k = k + 1) wram_sim_b[k] = 8'h00;
        ss_load = 1; tick; ss_load = 0;
        wait(ss_freeze_b);
        wait(!ss_freeze_b);'''

new_block = '''        $display("Candidato abortou para ST_IDLE e liberou freeze perfeitamente. Testando ciclo subsequente...");
        // Executa novo SAVE e LOAD normal no candidato para garantir integridade apos aborto
        init_wram(8192, 8'h42);
        $display("Disparando ss_save pos-aborto...");
        ss_save = 1; tick; ss_save = 0;
        wait(ss_freeze_b);
        $display("Freeze ativo para SAVE pos-aborto...");
        wait(!ss_freeze_b);
        $display("SAVE pos-aborto concluido!");
        repeat (10) tick;
        for (integer k = 0; k < 8192; k = k + 1) wram_sim_b[k] = 8'h00;
        $display("Disparando ss_load pos-aborto...");
        ss_load = 1; tick; ss_load = 0;
        wait(ss_freeze_b);
        $display("Freeze ativo para LOAD pos-aborto...");
        wait(!ss_freeze_b);
        $display("LOAD pos-aborto concluido!");'''

text = text.replace(old_block, new_block)
with open('tests/savestate_op_cooldown_removal/sim/cooldown_verification_tb.sv', 'w') as f:
    f.write(text)
print('Added debug prints successfully.')

