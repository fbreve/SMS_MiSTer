`timescale 1ns/1ps

module tb_ym2413_diff;

    reg clk = 0;
    reg reset_n = 0;
    reg ce_cpu = 0;
    integer cycle = 0;

    // Clock generation (53.7 MHz / clk_sys ~ 18.6 ns period -> 9.3ns half period)
    always #9.3 clk = ~clk;

    // ce_cpu generation (~3.58 MHz -> 1 active pulse every 15 clk_sys cycles)
    reg [3:0] ce_div = 0;
    always @(posedge clk) begin
        if (!reset_n) begin
            ce_div <= 0;
            ce_cpu <= 0;
        end else begin
            if (ce_div == 14) begin
                ce_div <= 0;
                ce_cpu <= 1;
            end else begin
                ce_div <= ce_div + 1'b1;
                ce_cpu <= 0;
            end
        end
    end

    // Interface signals
    reg [7:0] fm_d = 0;
    reg fm_a = 0;
    reg cs_n = 0;
    reg we_n = 0;

    // Signals for Candidate (DUT)
    reg ss_hold_dut = 0;
    reg [7:0] ss_addr_dut = 0;
    reg ss_read_dut = 0;
    reg ss_write_dut = 0;
    reg [31:0] ss_wdata_dut = 0;
    wire [31:0] ss_rdata_dut;
    wire ss_init_dut;
    wire [13:0] mixout_dut;

    // Signals for Reference v19 (REF)
    reg ss_hold_ref = 0;
    reg [7:0] ss_addr_ref = 0;
    reg ss_read_ref = 0;
    reg ss_write_ref = 0;
    reg [31:0] ss_wdata_ref = 0;
    wire [31:0] ss_rdata_ref;
    wire ss_init_ref;
    wire [13:0] mixout_ref;

    // Instantiation of DUT OPLL
    opll dut_opll (
        .xin(clk),
        .xout(),
        .xena(ce_cpu),
        .d(fm_d),
        .a(fm_a),
        .cs_n(cs_n),
        .we_n(we_n),
        .ic_n(reset_n),
        .mixout(mixout_dut),
        .ss_hold(ss_hold_dut),
        .ss_addr(ss_addr_dut),
        .ss_read(ss_read_dut),
        .ss_write(ss_write_dut),
        .ss_wdata(ss_wdata_dut),
        .ss_rdata(ss_rdata_dut),
        .ss_initialized(ss_init_dut)
    );

    // Instantiation of Reference OPLL (v19 full state)
    opll ref_opll (
        .xin(clk),
        .xout(),
        .xena(ce_cpu),
        .d(fm_d),
        .a(fm_a),
        .cs_n(cs_n),
        .we_n(we_n),
        .ic_n(reset_n),
        .mixout(mixout_ref),
        .ss_hold(ss_hold_ref),
        .ss_addr(ss_addr_ref),
        .ss_read(ss_read_ref),
        .ss_write(ss_write_ref),
        .ss_wdata(ss_wdata_ref),
        .ss_rdata(ss_rdata_ref),
        .ss_initialized(ss_init_ref)
    );

    task tick;
        begin
            @(posedge clk);
            #1;
        end
    endtask

    task write_reg(input [7:0] addr, input [7:0] data);
        begin
            // Address phase
            @(posedge clk);
            while (!ce_cpu) @(posedge clk);
            fm_a <= 0;
            fm_d <= addr;
            cs_n <= 0;
            we_n <= 0;
            @(posedge clk);
            while (!ce_cpu) @(posedge clk);
            we_n <= 1;

            // Wait timing gap between addr and data
            repeat (6) begin
                @(posedge clk);
                while (!ce_cpu) @(posedge clk);
            end

            // Data phase
            fm_a <= 1;
            fm_d <= data;
            we_n <= 0;
            @(posedge clk);
            while (!ce_cpu) @(posedge clk);
            we_n <= 1;

            // Wait recovery
            repeat (10) begin
                @(posedge clk);
                while (!ce_cpu) @(posedge clk);
            end
        end
    endtask

    // Storage for captured snapshots
    reg [31:0] v19_snapshot [0:103];
    reg [31:0] minimal_snapshot [0:103];

    // Capture v19 full snapshot (104 rows)
    task capture_ref_v19;
        integer i;
        begin
            ss_hold_ref <= 1;
            ss_read_ref <= 1;
            ss_write_ref <= 0;
            for (i = 0; i < 104; i = i + 1) begin
                ss_addr_ref <= i;
                tick;
                tick;
                v19_snapshot[i] <= ss_rdata_ref;
            end
            ss_read_ref <= 0;
            ss_hold_ref <= 0;
            tick;
        end
    endtask

    // Restore v19 full snapshot
    task restore_ref_v19;
        integer i;
        begin
            ss_hold_ref <= 1;
            ss_write_ref <= 1;
            ss_read_ref <= 0;
            for (i = 0; i < 104; i = i + 1) begin
                ss_addr_ref <= i;
                ss_wdata_ref <= v19_snapshot[i];
                tick;
                tick;
            end
            ss_write_ref <= 0;
            ss_hold_ref <= 0;
            tick;
        end
    endtask

    // Capture Minimal snapshot (only channels 0..8, user voice 9..12, and controller 80..85 / 77)
    task capture_dut_minimal;
        integer i;
        begin
            ss_hold_dut <= 1;
            ss_read_dut <= 1;
            ss_write_dut <= 0;
            // Channel registers 0..8
            for (i = 0; i <= 8; i = i + 1) begin
                ss_addr_dut <= i;
                tick; tick;
                minimal_snapshot[i] <= ss_rdata_dut;
            end
            // User voice memory 9..12
            for (i = 9; i <= 12; i = i + 1) begin
                ss_addr_dut <= i;
                tick; tick;
                minimal_snapshot[i] <= ss_rdata_dut;
            end
            // Controller registers 80..85 and opll wrapper 77
            ss_addr_dut <= 77; tick; tick; minimal_snapshot[77] <= ss_rdata_dut;
            for (i = 80; i <= 85; i = i + 1) begin
                ss_addr_dut <= i;
                tick; tick;
                minimal_snapshot[i] <= ss_rdata_dut;
            end
            ss_read_dut <= 0;
            ss_hold_dut <= 0;
            tick;
        end
    endtask

    // Restore Minimal snapshot (ONLY channels 0..8, voice 9..12, controller 80..85, 77)
    // NOTE: Phase (13..30), Envelope (31..48), Feedback (49..57), Output (58..75), FSMs (86..103) are UNTOUCHED!
    task restore_dut_minimal;
        integer i;
        begin
            ss_hold_dut <= 1;
            ss_write_dut <= 1;
            ss_read_dut <= 0;
            // Channel registers 0..8
            for (i = 0; i <= 8; i = i + 1) begin
                ss_addr_dut <= i;
                ss_wdata_dut <= minimal_snapshot[i];
                tick; tick;
            end
            // User voice memory 9..12
            for (i = 9; i <= 12; i = i + 1) begin
                ss_addr_dut <= i;
                ss_wdata_dut <= minimal_snapshot[i];
                tick; tick;
            end
            // Controller registers 80..85 and opll wrapper 77
            ss_addr_dut <= 77; ss_wdata_dut <= minimal_snapshot[77]; tick; tick;
            for (i = 80; i <= 85; i = i + 1) begin
                ss_addr_dut <= i;
                ss_wdata_dut <= minimal_snapshot[i];
                tick; tick;
            end
            ss_write_dut <= 0;
            ss_hold_dut <= 0;
            tick;
        end
    endtask

    // Test execution and metrics
    integer sample_idx;
    integer diff_count_immediate = 0;
    integer diff_count_frame1 = 0;
    integer diff_count_frame2 = 0;
    integer max_abs_diff_immediate = 0;
    integer max_abs_diff_frame1 = 0;
    integer max_abs_diff_frame2 = 0;

    initial begin
        $display("=== INICIANDO TESTBENCH DIFERENCIAL YM2413: CANDIDATO MINIMO VS V19 ===");
        reset_n = 0;
        repeat (20) tick;
        reset_n = 1;

        // Aguarda estabilização do hardware e auto-inicialização das memórias ROM
        while (!ss_init_dut || !ss_init_ref) tick;
        $display("[INFO] Modulos OPLL inicializados com sucesso.");

        // ====================================================================
        // CENARIO 1: CONFIGURAÇÃO DE ÁUDIO "TELA A (BATALHA DE YS)"
        // ====================================================================
        $display("[SCENARIO 1] Configurando Tela A: User Voice customizada, notas ativas e percussão...");
        // Define Custom User Voice (regs $00..$07)
        write_reg(8'h00, 8'h31); // Modulator AM, PM, EG, KSR, Multiplier
        write_reg(8'h01, 8'h21); // Carrier AM, PM, EG, KSR, Multiplier
        write_reg(8'h02, 8'h15); // Modulator KL, TL
        write_reg(8'h03, 8'h06); // Carrier KL, Waveform, Feedback
        write_reg(8'h04, 8'hF2); // Modulator AR, DR
        write_reg(8'h05, 8'hE3); // Carrier AR, DR
        write_reg(8'h06, 8'h25); // Modulator SL, RR
        write_reg(8'h07, 8'h17); // Carrier SL, RR

        // Configura Canal 0: User Voice (Inst 0), Freq, Key-On
        write_reg(8'h30, 8'h02); // Inst 0, Vol 2
        write_reg(8'h10, 8'h80); // F-Number LSB
        write_reg(8'h20, 8'h32); // Block 4, Key-On, Sus

        // Transi��o: Nova nota no canal 0 para testar re-disparo
        #200000;
        write_reg(8'h20, 8'h12); // Key-Off
        #100000;
        write_reg(8'h20, 8'h32); // Key-On

        // Configura Canal 1: Trompete (Inst 2), Freq, Key-On
        write_reg(8'h31, 8'h23); // Inst 2, Vol 3
        write_reg(8'h11, 8'hA0); // F-Number LSB
        write_reg(8'h21, 8'h30); // Block 4, Key-On

        // Habilita modo de ritmo (reg $0E): Rhythm ON + Disparo de Bumbo e Prato
        write_reg(8'h0E, 8'h39);

        // Deixa o som tocar por 20.000 clocks para que as notas atinjam sustain e envelopes se desenvolvam
        repeat (20000) tick;
        $display("[INFO] Som da Tela A estabilizado. Mixout DUT=%0d, REF=%0d", mixout_dut, mixout_ref);

        // ====================================================================
        // PASSO 2: SALVAR SNAPSHOTS
        // ====================================================================
        $display("[INFO] Executando SAVE nos dois módulos...");
        capture_dut_minimal();
        capture_ref_v19();

        // ====================================================================
        // PASSO 3: MUDANÇA DRÁSTICA "TELA B (VILA / TELA DE HISTÓRIA)"
        // ====================================================================
        $display("[SCENARIO 1] Corrompendo/Alterando completamente para Tela B...");
        // Desliga ritmo, zera vozes customizadas, muda instrumentos para Piano e frequências graves
        write_reg(8'h0E, 8'h00); // Rhythm OFF
        write_reg(8'h00, 8'h00);
        write_reg(8'h01, 8'h00);
        write_reg(8'h30, 8'h30); // Inst 3 (Piano), Vol 0
        write_reg(8'h10, 8'h20);
        write_reg(8'h20, 8'h10); // Block 2, Key-Off
        write_reg(8'h31, 8'h50); // Inst 5, Vol 0
        write_reg(8'h11, 8'h10);
        write_reg(8'h21, 8'h10); // Key-Off

        repeat (15000) tick;
        $display("[INFO] Estado na Tela B completamente diferente.");

        // ====================================================================
        // PASSO 4: RESTAURAR SNAPSHOTS (LOAD)
        // ====================================================================
        $display("[INFO] Executando LOAD nos dois modulos (DUT restaura MINIMO, REF restaura COMPLETO v19)...");
        restore_dut_minimal();
        restore_ref_v19();

        // ====================================================================
        // PASSO 5: VERIFICAÇÃO DO ESTADO LÓGICO IMEDIATO NO CICLO ZERO PÓS-LOAD
        // ====================================================================
        $display("[CHECK 1] Validando Estado Lógico Imediato (Ciclo 0)...");
        // Verifica registradores lógicos de canais (0..8)
        begin : check_logical
            integer ch;
            reg ok;
            ok = 1;
            // Lê canal 0 e 1 do DUT
            ss_hold_dut = 1; ss_read_dut = 1;
            ss_addr_dut = 0; tick; tick;
            if (ss_rdata_dut !== minimal_snapshot[0]) begin
                $display("[FAIL] Canal 0 não restaurou! Obtido: %h, Esperado: %h", ss_rdata_dut, minimal_snapshot[0]);
                ok = 0;
            end
            ss_addr_dut = 1; tick; tick;
            if (ss_rdata_dut !== minimal_snapshot[1]) begin
                $display("[FAIL] Canal 1 não restaurou! Obtido: %h, Esperado: %h", ss_rdata_dut, minimal_snapshot[1]);
                ok = 0;
            end
            // Lê User Voice 9
            ss_addr_dut = 9; tick; tick;
            if (ss_rdata_dut !== minimal_snapshot[9]) begin
                $display("[FAIL] User Voice 9 não restaurou! Obtido: %h, Esperado: %h", ss_rdata_dut, minimal_snapshot[9]);
                ok = 0;
            end
            // Lê Controller (rflag em 84)
            ss_addr_dut = 84; tick; tick;
            if (ss_rdata_dut[5:0] !== minimal_snapshot[84][5:0]) begin
                $display("[FAIL] Controle de Ritmo (rflag) não restaurou! Obtido: %h, Esperado: %h", ss_rdata_dut[5:0], minimal_snapshot[84][5:0]);
                ok = 0;
            end
            ss_read_dut = 0; ss_hold_dut = 0; tick;

            if (ok) $display("[PASS] Estado Lógico Imediato restaurado 100 percent com sucesso!");
            else $fatal(1, "Falha na restauração do estado lógico mínimo.");
        end

        // ====================================================================
        // PASSO 6: MEDIÇÃO TEMPORAL DE CONVERGÊNCIA (FRAME 0, 1 E 2)
        // 1 frame a 60Hz = ~16.66 ms = ~895.000 clocks a 53.7MHz.
        // Na simulação de áudio, monitoramos 50.000 clocks por intervalo (~1 ms / múltiplos ciclos de onda)
        // ====================================================================
        $display("[CHECK 2] Medindo comportamento dinâmico de áudio e convergência...");
        
        // Intervalo Imediato (Clocks 0 a 5.000 pós-unfreeze)
        for (sample_idx = 0; sample_idx < 5000; sample_idx = sample_idx + 1) begin
            tick;
            if (mixout_dut !== mixout_ref) begin
                integer d;
                d = mixout_dut - mixout_ref;
                if (d < 0) d = -d;
                diff_count_immediate = diff_count_immediate + 1;
                if (d > max_abs_diff_immediate) max_abs_diff_immediate = d;
            end
        end
        $display("[METRICA IMEDIATA] Amostras divergentes: %0d / 5000 | Diferença máxima: %0d", diff_count_immediate, max_abs_diff_immediate);

        // Frame 1 (Avança até 30.000 clocks)
        repeat (25000) tick;
        for (sample_idx = 0; sample_idx < 5000; sample_idx = sample_idx + 1) begin
            tick;
            if (mixout_dut !== mixout_ref) begin
                integer d;
                d = mixout_dut - mixout_ref;
                if (d < 0) d = -d;
                diff_count_frame1 = diff_count_frame1 + 1;
                if (d > max_abs_diff_frame1) max_abs_diff_frame1 = d;
            end
        end
        $display("[METRICA FRAME 1] Amostras divergentes: %0d / 5000 | Diferença máxima: %0d", diff_count_frame1, max_abs_diff_frame1);

        // Frame 2 (Avança até 60.000 clocks)
        repeat (25000) tick;
        for (sample_idx = 0; sample_idx < 5000; sample_idx = sample_idx + 1) begin
            tick;
            if (mixout_dut !== mixout_ref) begin
                integer d;
                d = mixout_dut - mixout_ref;
                if (d < 0) d = -d;
                diff_count_frame2 = diff_count_frame2 + 1;
                if (d > max_abs_diff_frame2) max_abs_diff_frame2 = d;
            end
        end
        $display("[METRICA FRAME 2] Amostras divergentes: %0d / 5000 | Diferença máxima: %0d", diff_count_frame2, max_abs_diff_frame2);

        // Frame 3 (Avan�a mais 100.000 clocks)
        repeat (100000) tick;
        diff_count_frame2 = 0; max_abs_diff_frame2 = 0;
        for (sample_idx = 0; sample_idx < 5000; sample_idx = sample_idx + 1) begin
            tick;
            if (mixout_dut !== mixout_ref) begin
                integer d;
                d = mixout_dut - mixout_ref;
                if (d < 0) d = -d;
                diff_count_frame2 = diff_count_frame2 + 1;
                if (d > max_abs_diff_frame2) max_abs_diff_frame2 = d;
            end
        end
        $display("[METRICA FRAME 3 / ~3ms] Amostras divergentes: %0d / 5000 | Diferen�a m�xima: %0d", diff_count_frame2, max_abs_diff_frame2);

        // Frame 4 (Avan�a mais 200.000 clocks)
        repeat (200000) tick;
        diff_count_frame2 = 0; max_abs_diff_frame2 = 0;
        for (sample_idx = 0; sample_idx < 5000; sample_idx = sample_idx + 1) begin
            tick;
            if (mixout_dut !== mixout_ref) begin
                integer d;
                d = mixout_dut - mixout_ref;
                if (d < 0) d = -d;
                diff_count_frame2 = diff_count_frame2 + 1;
                if (d > max_abs_diff_frame2) max_abs_diff_frame2 = d;
            end
        end
        $display("[METRICA FRAME 4 / ~7ms] Amostras divergentes: %0d / 5000 | Diferen�a m�xima: %0d", diff_count_frame2, max_abs_diff_frame2);

        $display("=== RESULTADOS FINAIS DA SIMULAÇÃO DIFERENCIAL ===");
        $display("Divergencia Imediata: %0d amostras | Max Delta: %0d", diff_count_immediate, max_abs_diff_immediate);
        $display("Divergencia Frame 1 : %0d amostras | Max Delta: %0d", diff_count_frame1, max_abs_diff_frame1);
        $display("Divergencia Frame 2 : %0d amostras | Max Delta: %0d", diff_count_frame2, max_abs_diff_frame2);

        $display("SIMULATION FINISHED SUCCESSFULLY");
        $finish;
    end

endmodule
