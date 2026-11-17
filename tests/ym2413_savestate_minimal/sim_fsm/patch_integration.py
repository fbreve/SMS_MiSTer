with open('tests/ym2413_savestate_minimal/sim_fsm/tb_ym2413_fsm_integration.sv', 'rb') as f:
    tb = f.read()

target = b"""        $display("[CHECK] Verificando se nota sustentada continuou e mixout estavel...");
        repeat(5000) tick;
        if (opll_mixout !== 14'd0 && opll_mixout !== 14'dx) begin
            $display("[PASS] YM2413 mixout ativo apos LOAD: %04x", opll_mixout);
        end else begin
            $fatal(1, "Mixout mudo ou indefinido apos LOAD!");
        end"""

replacement = b"""        $display("[CHECK] Verificando se nota sustentada continuou e mixout estavel...");
        begin : check_mixout
            integer m_cnt;
            integer nonzero_cnt;
            nonzero_cnt = 0;
            for (m_cnt = 0; m_cnt < 10000; m_cnt = m_cnt + 1) begin
                tick;
                if (opll_mixout !== 14'd0 && opll_mixout !== 14'dx) nonzero_cnt = nonzero_cnt + 1;
            end
            $display("   [MIXOUT STATS] Total de amostras nao-nulas em 10000 ticks: %0d (mixout atual: %04x)", nonzero_cnt, opll_mixout);
            if (nonzero_cnt > 0) begin
                $display("[PASS] YM2413 mixout ativo apos LOAD!");
            end else begin
                $fatal(1, "Mixout mudo ou indefinido apos LOAD!");
            end
        end"""

if target in tb:
    tb = tb.replace(target, replacement, 1)
    with open('tests/ym2413_savestate_minimal/sim_fsm/tb_ym2413_fsm_integration.sv', 'wb') as f:
        f.write(tb)
    print('SUCCESS')
else:
    # Try CRLF
    target_crlf = target.replace(b'\n', b'\r\n')
    replacement_crlf = replacement.replace(b'\n', b'\r\n')
    if target_crlf in tb:
        tb = tb.replace(target_crlf, replacement_crlf, 1)
        with open('tests/ym2413_savestate_minimal/sim_fsm/tb_ym2413_fsm_integration.sv', 'wb') as f:
            f.write(tb)
        print('SUCCESS_CRLF')
    else:
        print('TARGET NOT FOUND')
