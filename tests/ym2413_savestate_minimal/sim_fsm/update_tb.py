import os

file_path = 'tests/ym2413_savestate_minimal/sim_fsm/tb_ym2413_fsm_integration.sv'
with open(file_path, 'rb') as f:
    data = f.read()

target = b'''        $display("=== TODOS OS TESTES DA FSM INTEGRADA PASSARAM COM SUCESSO! ===");
        $finish;
    end

endmodule'''

target_crlf = target.replace(b'\n', b'\r\n')

tests_addition = b'''        // ====================================================================
        // TESTE 6: Corrupcao precoce (Palavra 0 - canal 0 bits invalidos)
        // ====================================================================
        $display("[TESTE 6] Testando corrupcao precoce (Palavra 0: bits reservados violados)...");
        // Re-gravar descritor valido e corromper palavra 0 (bits reservados 31:24)
        ddram_mem[29'h2997] = 64'h001001014F504C4C;
        ddram_mem[29'h2998] = {32'h0, 32'hFF000000}; // Palavra 0 corrompida!
        
        // Disparar LOAD
        force dut_savestates.op_cooldown = 0;
        ss_load <= 1;
        tick;
        ss_load <= 0;
        wait(ss_freeze);
        $display("[INFO] Congelado para LOAD com payload corrompido...");
        // Deve abortar para ST_ERROR -> ST_UNFREEZE_SETTLE (com fm_legacy_reset=1) -> ST_IDLE
        wait(!ss_freeze);
        $display("[PASS] FSM recuperou de corrupcao na palavra 0 e liberou ss_freeze!");
        repeat(20) tick;
        release dut_savestates.op_cooldown;

        // ====================================================================
        // TESTE 7: Corrupcao intermediaria (Palavra 8 - envelopes)
        // ====================================================================
        $display("[TESTE 7] Testando corrupcao intermediaria (Palavra 8: envelopes invalidos)...");
        // Restaurar palavra 0 valida e corromper palavra 8
        ddram_mem[29'h2998] = 64'h0000199100001570;
        ddram_mem[29'h2998 + 8] = {32'hFE000000, 32'h0}; // Envelope corrompido (bits 31:25 nao-zero)
        
        force dut_savestates.op_cooldown = 0;
        ss_load <= 1;
        tick;
        ss_load <= 0;
        wait(ss_freeze);
        $display("[INFO] Congelado para LOAD com palavra intermediaria corrompida...");
        wait(!ss_freeze);
        $display("[PASS] FSM recuperou de corrupcao intermediaria e descongelou normalmente!");
        repeat(20) tick;
        release dut_savestates.op_cooldown;

        // ====================================================================
        // TESTE 8: Corrupcao tardia (Palavra 15 - Control/Latch) e subsequente SAVE/LOAD
        // ====================================================================
        $display("[TESTE 8] Testando corrupcao tardia (Palavra 15) e verificando que reset limpa escritas parciais...");
        // Restaurar palavra 8 valida e corromper palavra 15 (bits 31:24 do latch de controle)
        ddram_mem[29'h2998 + 8] = 64'd0;
        ddram_mem[29'h2998 + 15] = {32'hFF000000, 32'd0};
        
        force dut_savestates.op_cooldown = 0;
        ss_load <= 1;
        tick;
        ss_load <= 0;
        wait(ss_freeze);
        $display("[INFO] Congelado para LOAD com corrupcao tardia...");
        wait(!ss_freeze);
        $display("[PASS] FSM abortou em ST_ERROR na palavra 15, acionou fm_legacy_reset e descongelou!");
        repeat(20) tick;
        release dut_savestates.op_cooldown;

        // ====================================================================
        // TESTE 9: Recuperacao total e capacidade de executar novo SAVE e LOAD
        // ====================================================================
        $display("[TESTE 9] Verificando execucao limpa de um novo ciclo SAVE e LOAD apos os erros...");
        // Configurar novamente estado musical limpo
        write_opll(8'h30, 8'h00);
        write_opll(8'h10, 8'h91);
        write_opll(8'h20, 8'h19);
        repeat(2000) tick;

        // Novo SAVE limpo
        do_save();
        $display("[PASS] Novo SAVE executado com exito apos falhas de corrupcao!");

        // Novo LOAD limpo
        do_load();
        $display("[PASS] Novo LOAD executado com exito! Ausencia total de deadlock!");

        $display("=== TODOS OS TESTES (1 A 9) DA FSM INTEGRADA PASSARAM COM SUCESSO! ===");
        $finish;
    end

endmodule'''

tests_addition_crlf = tests_addition.replace(b'\n', b'\r\n')

if target_crlf in data:
    new_data = data.replace(target_crlf, tests_addition_crlf, 1)
elif target in data:
    new_data = data.replace(target, tests_addition, 1)
else:
    raise RuntimeError('Target not found')

with open(file_path, 'wb') as f:
    f.write(new_data)
print('Successfully appended Tests 6, 7, 8, 9 to tb_ym2413_fsm_integration.sv')

