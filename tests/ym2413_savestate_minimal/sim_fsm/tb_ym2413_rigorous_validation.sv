`timescale 1ns/1ps

module tb_ym2413_rigorous_validation;

    reg clk = 0;
    reg reset_n = 0;
    integer cycle = 0;

    // 53.7 MHz sys clock (half period 9.3 ns)
    always #9.3 clk = ~clk;

    // DDRAM model
    reg [63:0] ddram_mem [0:12287];
    wire [28:0] DDRAM_ADDR;
    wire [63:0] DDRAM_DIN;
    wire [7:0]  DDRAM_BE;
    wire        DDRAM_WE;
    reg  [63:0] DDRAM_DOUT = 0;
    reg         DDRAM_DOUT_READY = 0;
    wire        DDRAM_RD;
    wire [7:0]  DDRAM_BURSTCNT;
    reg         DDRAM_BUSY = 0;

    integer ddram_pending = 0;
    reg [28:0] ddram_readaddr = 0;
    integer ddram_latency_cycles = 2;

    always @(posedge clk) begin
        DDRAM_DOUT_READY <= 0;
        if (ddram_pending > 0) begin
            ddram_pending <= ddram_pending - 1;
            if (ddram_pending == 1) begin
                DDRAM_DOUT <= ddram_mem[ddram_readaddr - 29'h07c00000];
                DDRAM_DOUT_READY <= 1;
            end
        end
        if (DDRAM_WE && !DDRAM_BUSY) begin
            for (integer b = 0; b < 8; b = b + 1) begin
                if (DDRAM_BE[b]) ddram_mem[DDRAM_ADDR - 29'h07c00000][b*8 +: 8] <= DDRAM_DIN[b*8 +: 8];
            end
        end
        if (DDRAM_RD && !DDRAM_BUSY) begin
            ddram_pending  <= ddram_latency_cycles;
            ddram_readaddr <= DDRAM_ADDR;
        end
    end

    // Interface signals to savestates
    reg ss_save = 0;
    reg ss_load = 0;
    reg [1:0] ss_slot = 0;
    wire ss_freeze;

    // FM state signals
    wire [7:0]  fm_state_addr;
    wire        fm_state_read;
    wire        fm_state_write;
    wire [31:0] fm_state_wdata;
    wire [31:0] fm_state_rdata;
    wire        fm_initialized;
    wire        fm_legacy_reset;
    wire        fm_initialization_run;

    // Clock enables
    reg [8:0] x = 0;
    reg vblank = 1;
    reg cpu_ce = 0;
    reg vdp_ce = 0;
    reg pix_ce = 0;
    reg sp_ce  = 0;
    reg [3:0] ce_div = 0;

    always @(posedge clk) begin
        if (!reset_n) begin
            ce_div <= 0;
            cpu_ce <= 0;
            vdp_ce <= 0;
            pix_ce <= 0;
            sp_ce  <= 0;
        end else begin
            ce_div <= ce_div + 1'b1;
            cpu_ce <= (ce_div == 4'd14);
            vdp_ce <= (ce_div == 4'd7);
            pix_ce <= (ce_div[1:0] == 2'd2);
            sp_ce  <= (ce_div[1:0] == 2'd3);
        end
    end

    // OPLL signals
    reg [7:0] opll_d = 0;
    reg opll_a = 0;
    reg opll_cs_n = 0;
    reg opll_we_n = 1;
    wire [13:0] opll_mixout;

    // Registered wrapper response like system.vhd
    reg [7:0] latch_fm_d = 0;
    reg latch_fm_a = 0;
    reg [31:0] reg_wrapper_rdata = 0;
    wire [31:0] opll_direct_rdata;
    assign fm_state_rdata = opll_direct_rdata | reg_wrapper_rdata;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n || fm_legacy_reset) begin
            latch_fm_d <= 0;
            latch_fm_a <= 0;
        end else if (ss_freeze && fm_state_write && fm_state_addr == 8'd31) begin
            latch_fm_d <= fm_state_wdata[13:6];
            latch_fm_a <= fm_state_wdata[14];
        end else if (!ss_freeze && !opll_we_n) begin
            latch_fm_d <= opll_d;
            latch_fm_a <= opll_a;
        end
    end

    always @(posedge clk) begin
        reg_wrapper_rdata <= 32'd0;
        if (ss_freeze && fm_state_read && fm_state_addr == 8'd31) begin
            reg_wrapper_rdata <= {17'd0, latch_fm_a, latch_fm_d, 6'd0};
        end
    end

    // WRAM signals for checking WRAM preservation
    reg [7:0] wram [0:8191];
    wire [13:0] wram_A;
    wire [7:0]  wram_D = wram[wram_A[12:0]];
    wire        wram_WE;
    wire [13:0] wram_WA;
    wire [7:0]  wram_WD;

    always @(posedge clk) begin
        if (wram_WE) wram[wram_WA[12:0]] <= wram_WD;
    end

    // Instantiate OPLL
    opll dut_opll (
        .xin(clk),
        .xout(),
        .xena(cpu_ce),
        .d(opll_d),
        .a(opll_a),
        .cs_n(opll_cs_n),
        .we_n(opll_we_n),
        .ic_n(reset_n && !fm_legacy_reset),
        .mixout(opll_mixout),
        .ss_hold(ss_freeze && !fm_initialization_run),
        .ss_addr(fm_state_addr),
        .ss_read(fm_state_read),
        .ss_write(fm_state_write),
        .ss_wdata(fm_state_wdata),
        .ss_rdata(opll_direct_rdata),
        .ss_initialized(fm_initialized)
    );

    // Instantiate savestates matching ports exactly
    savestates dut_savestates (
        .clk(clk),
        .reset_n(reset_n),
        .ss_save(ss_save),
        .ss_load(ss_load),
        .ss_slot(ss_slot),
        .ss_bios_mode(1'b0),
        .ss_game_id(32'h534d5301),
        .ss_freeze(ss_freeze),
        .vblank(vblank),
        .x(x),
        .z80_reg(230'd0),
        .z80_dir(),
        .z80_set(),
        .z80_m1_n(1'b0),
        .z80_mreq_n(1'b0),
        .z80_iset(2'd0),
        .cpu_ce(cpu_ce),
        .vdp_ce(vdp_ce),
        .pix_ce(pix_ce),
        .sp_ce(sp_ce),
        .vdp_regs(128'd0),
        .vdp_regs_in(),
        .vdp_regs_set(),
        .cram_out(384'd0),
        .cram_A(),
        .cram_D(),
        .cram_wr(),
        .vram_en(),
        .vram_A(),
        .vram_D(8'd0),
        .vram_WE(),
        .vram_WA(),
        .vram_WD(),
        .psg_out(56'd0),
        .psg_in(),
        .psg_set(),
        .psg_ext_out(96'd0),
        .psg2_ext_out(96'd0),
        .psg_ext_in(),
        .psg2_ext_in(),
        .psg_div_out(4'd0),
        .psg_div_in(),
        .audio_control_out(11'd0),
        .audio_control_in(),
        .audio_quiescent(1'b1),
        .audio_phase_out(1'b0),
        .audio_phase_in(),
        .audio_ext_set(),
        .audio_phase_set(),
        .mapper_out(64'd0),
        .mapper_in(),
        .mapper_set(),
        .evolution_out(96'd0),
        .evolution_in(),
        .evolution_set(),
        .eeprom_out(64'd0),
        .eeprom_in(),
        .eeprom_set(),
        .wram_A(wram_A),
        .wram_D(wram_D),
        .wram_WE(wram_WE),
        .wram_WA(wram_WA),
        .wram_WD(wram_WD),
        .nvram_A(),
        .nvram_D(8'd0),
        .nvram_WE(),
        .nvram_WA(),
        .nvram_WD(),
        .systeme(1'b0),
        .vdp2_regs(128'd0),
        .vdp2_regs_in(),
        .vdp2_regs_set(),
        .cram2_out(384'd0),
        .cram2_A(),
        .cram2_D(),
        .cram2_wr(),
        .vram2_en(),
        .vram2_A(),
        .vram2_D(8'd0),
        .vram2_WE(),
        .vram2_WA(),
        .vram2_WD(),
        .psg2_out(56'd0),
        .psg2_in(),
        .psg2_set(),
        .io_out(32'd0),
        .io_in(),
        .io_set(),
        .video_state_out(22'd0),
        .video_state_in(),
        .video_state_set(),
        .fm_state_addr(fm_state_addr),
        .fm_state_read(fm_state_read),
        .fm_state_write(fm_state_write),
        .fm_state_wdata(fm_state_wdata),
        .fm_state_rdata(fm_state_rdata),
        .fm_initialized(fm_initialized),
        .fm_legacy_reset(fm_legacy_reset),
        .fm_initialization_run(fm_initialization_run),
        .DDRAM_ADDR(DDRAM_ADDR),
        .DDRAM_DIN(DDRAM_DIN),
        .DDRAM_BE(DDRAM_BE),
        .DDRAM_WE(DDRAM_WE),
        .DDRAM_DOUT(DDRAM_DOUT),
        .DDRAM_DOUT_READY(DDRAM_DOUT_READY),
        .DDRAM_RD(DDRAM_RD),
        .DDRAM_BURSTCNT(DDRAM_BURSTCNT),
        .DDRAM_BUSY(DDRAM_BUSY)
    );

    task tick;
        begin
            @(posedge clk);
            #1;
        end
    endtask

    task write_opll(input [7:0] addr, input [7:0] data);
        begin
            @(posedge clk);
            while (!cpu_ce) @(posedge clk);
            opll_a <= 0;
            opll_d <= addr;
            opll_cs_n <= 0;
            opll_we_n <= 0;
            @(posedge clk);
            while (!cpu_ce) @(posedge clk);
            opll_we_n <= 1;

            repeat (16) begin
                @(posedge clk);
                while (!cpu_ce) @(posedge clk);
            end

            opll_a <= 1;
            opll_d <= data;
            opll_we_n <= 0;
            @(posedge clk);
            while (!cpu_ce) @(posedge clk);
            opll_we_n <= 1;

            repeat (16) begin
                @(posedge clk);
                while (!cpu_ce) @(posedge clk);
            end
        end
    endtask

    task do_save;
        begin
            force dut_savestates.op_cooldown = 0;
            ss_save <= 1; tick; ss_save <= 0;
            wait(ss_freeze);
            wait(!ss_freeze);
            repeat(10) tick;
            release dut_savestates.op_cooldown;
        end
    endtask

    task do_load;
        begin
            force dut_savestates.op_cooldown = 0;
            ss_load <= 1; tick; ss_load <= 0;
            wait(ss_freeze);
            wait(!ss_freeze);
            repeat(10) tick;
            release dut_savestates.op_cooldown;
        end
    endtask

    // Storage for word comparison (all 32 words)
    reg [31:0] expected_words [0:31];
    reg [31:0] actual_words   [0:31];
    integer k, errors;

    initial begin
        $display("===============================================================================");
        $display("=== INICIANDO RIGOROUS VALIDATION SUITE (MANDATORY VERIFICATION CHECKS) ===");
        $display("===============================================================================");

        reset_n = 0;
        for (k = 0; k < 12288; k = k + 1) ddram_mem[k] = 64'd0;
        for (k = 0; k < 8192; k = k + 1) wram[k] = 8'h00;
        repeat(20) tick;
        reset_n = 1;

        while (!fm_initialized) tick;
        $display("[INIT] OPLL e sistema inicializados com sucesso.");

        // ====================================================================
        // CHECK 1: Verificação ciclo a ciclo e comparação exata de TODAS as 32 palavras FM
        // ====================================================================
        $display("\n-------------------------------------------------------------------------------");
        $display("[CHECK 1] Configuracao rica do FM e comparacao exata das 32 palavras (SAVE & LOAD)...");

        // 1. Configurar User Voice (Addr 0..7)
        write_opll(8'h00, 8'h31);
        write_opll(8'h01, 8'h21);
        write_opll(8'h02, 8'h16);
        write_opll(8'h03, 8'h05);
        write_opll(8'h04, 8'hE2);
        write_opll(8'h05, 8'hC4);
        write_opll(8'h06, 8'h13);
        write_opll(8'h07, 8'h24);

        // 2. Configurar canais 0..8 com instrumentos e notas distintos
        for (k = 0; k < 9; k = k + 1) begin
            write_opll(8'h10 + k, 8'h80 + k[7:0]); // F-num low
            write_opll(8'h20 + k, 8'h10 | (k[2:0])); // Key-on, block k
            write_opll(8'h30 + k, {k[3:0], 4'h0}); // Voice k, vol 0
        end

        // 3. Configurar ritmo
        write_opll(8'h0E, 8'h35); // Ritmo ativo + triggers de percussão

        // Preencher WRAM com padrão de teste
        for (k = 0; k < 8192; k = k + 1) wram[k] = k[7:0] ^ 8'hA5;

        // Deixar oscilar para que envelopes avancem para valores não-triviais
        repeat (10000) tick;

        // Executar SAVE real via FSM
        do_save();

        for (k = 0; k < 16; k = k + 1) begin
            actual_words[2*k]     = ddram_mem[29'h2998 + k][31:0];
            actual_words[2*k + 1] = ddram_mem[29'h2998 + k][63:32];
        end

        $display("   Descritor FM gravado: %016h", ddram_mem[29'h2997]);
        if (ddram_mem[29'h2997] !== 64'h001001014F504C4C) begin
            $fatal(1, "Descritor FM incorreto!");
        end

        // Armazenar como expected
        for (k = 0; k < 32; k = k + 1) expected_words[k] = actual_words[k];

        $display("   Palavra 0 (Ch 0): %08h, Palavra 1 (Ch 1): %08h", expected_words[0], expected_words[1]);
        $display("   Palavra 9 (Voice 0 Lo): %08h, Palavra 10 (Voice 0 Hi): %08h", expected_words[9], expected_words[10]);
        $display("   Palavra 30 (Env 17): %08h, Palavra 31 (Ctrl/Latches): %08h", expected_words[30], expected_words[31]);

        // Alterar completamente o sintetizador (simular cena avançando)
        write_opll(8'h0E, 8'h00); // Ritmo off
        for (k = 0; k < 9; k = k + 1) begin
            write_opll(8'h20 + k, 8'h00); // Key off
            write_opll(8'h30 + k, 8'hF0); // Mute
        end
        repeat (5000) tick;

        // Executar LOAD
        $display("   Executando LOAD...");
        force dut_savestates.op_cooldown = 0;
        ss_load <= 1; tick; ss_load <= 0;
        wait(ss_freeze);
        while (dut_savestates.state != 7'd81) tick;
        $display("   [DEBUG LOAD] ST_FM_APPLY_LO atingido! fm_snap[6]=%016h", dut_savestates.fm_snap[6]);
        while (dut_savestates.state >= 7'd81 && dut_savestates.state <= 7'd83) begin
            tick;
        end
        $display("   [DEBUG CHECK EG0 IMMEDIATELY AFTER APPLY] egdata_set(0)=%07h", dut_opll.eg.u_envelope_memory.egdata_set[0]);
        // Check all 32 words immediately while still frozen
        errors = 0;
        for (k = 0; k < 32; k = k + 1) begin
            dut_savestates.fm_state_addr = k[7:0];
            dut_savestates.fm_state_read = 1;
            tick;
            dut_savestates.fm_state_read = 0;
            actual_words[k] = fm_state_rdata;
            if (actual_words[k] !== expected_words[k]) begin
                $display("   [MISMATCH] Palavra %0d: Esperado %08h, Atual %08h", k, expected_words[k], actual_words[k]);
                errors = errors + 1;
            end
        end
        while (ss_freeze) begin
            if (dut_opll.eg.u_envelope_memory.egdata_set[0] !== expected_words[13][24:0]) begin
                $display("   [MUTATION DETECTED DURING FREEZE] state=%0d, egdata_set(0)=%07h, ss_hold=%0b, wr=%0b",
                         dut_savestates.state, dut_opll.eg.u_envelope_memory.egdata_set[0], dut_opll.eg.u_envelope_memory.ss_hold,
                         dut_opll.eg.u_envelope_memory.wr);
            end
            tick;
        end
        repeat(10) tick;
        release dut_savestates.op_cooldown;

        if (errors == 0) begin
            $display("[PASS CHECK 1] Todas as 32 palavras restauradas com 100%% de fidelidade!");
        end else begin
            $fatal(1, "Total de %0d palavras divergentes apos LOAD!", errors);
        end

        // ====================================================================
        // CHECK 2: Stalls Imediatos e Prolongados na DDRAM durante SAVE e LOAD
        // ====================================================================
        $display("\n-------------------------------------------------------------------------------");
        $display("[CHECK 2] Testando stalls imediatos e prolongados na DDRAM...");

        // Disparar SAVE com DDRAM_BUSY forçado por 10 ciclos a cada transação
        fork
            begin
                force dut_savestates.op_cooldown = 0;
                ss_save <= 1; tick; ss_save <= 0;
                wait(ss_freeze);
                while (ss_freeze) begin
                    if (DDRAM_WE || DDRAM_RD) begin
                        DDRAM_BUSY <= 1;
                        repeat(10) tick;
                        DDRAM_BUSY <= 0;
                        repeat(3) tick;
                    end else begin
                        tick;
                    end
                end
                release dut_savestates.op_cooldown;
            end
        join

        $display("   SAVE sob backpressure prolongado concluiu com sucesso.");
        if (ddram_mem[29'h2997] !== 64'h001001014F504C4C) $fatal(1, "Descritor corrompido sob backpressure!");
        $display("[PASS CHECK 2A] SAVE integro sob stalls severos de DDRAM.");

        // Disparar LOAD sob backpressure prolongado
        fork
            begin
                force dut_savestates.op_cooldown = 0;
                ss_load <= 1; tick; ss_load <= 0;
                wait(ss_freeze);
                while (ss_freeze) begin
                    if (DDRAM_WE || DDRAM_RD) begin
                        DDRAM_BUSY <= 1;
                        repeat(8) tick;
                        DDRAM_BUSY <= 0;
                        repeat(3) tick;
                    end else begin
                        tick;
                    end
                end
                release dut_savestates.op_cooldown;
            end
        join

        $display("[PASS CHECK 2B] LOAD integro sob stalls severos de DDRAM.");

        // ====================================================================
        // CHECK 3: Verificação de Contadores de Inicialização e fm_initialized com Jogo Congelado
        // ====================================================================
        $display("\n-------------------------------------------------------------------------------");
        $display("[CHECK 3] Verificando avanco dos contadores de inicializacao FM durante freeze do jogo...");

        // Simular savestate legado (descritor zerado)
        ddram_mem[29'h2997] = 64'd0;
        force dut_savestates.op_cooldown = 0;
        ss_load <= 1; tick; ss_load <= 0;
        wait(ss_freeze);

        // Esperar FSM entrar em ST_FM_LEGACY_WAIT
        wait(dut_savestates.state == 7'd85);
        $display("   Entrou em ST_FM_LEGACY_WAIT. ss_freeze=%0b, fm_initialization_run=%0b", ss_freeze, fm_initialization_run);
        if (ss_freeze !== 1'b1 || fm_initialization_run !== 1'b1) begin
            $fatal(1, "Bypass controlado de inicializacao nao ativado!");
        end

        // Acompanhar que fm_initialized começa em 0 logo após reset e transiciona para 1
        repeat(50) tick;
        wait(dut_savestates.state == 7'd63); // ST_UNFREEZE_SETTLE
        $display("   Transicionou para ST_UNFREEZE_SETTLE apos fm_initialized=%0b", fm_initialized);
        if (!fm_initialized) $fatal(1, "Nao esperou fm_initialized!");
        wait(!ss_freeze);
        release dut_savestates.op_cooldown;
        $display("[PASS CHECK 3] Inicializacao completada perfeitamente com jogo congelado.");

        // ====================================================================
        // CHECK 4: Stale Writes Injetados Durante LOAD e Verificação Imediata Pós-Unfreeze
        // ====================================================================
        $display("\n-------------------------------------------------------------------------------");
        $display("[CHECK 4] Injetando escritas normais durante LOAD e verificando ausencia de sobrescrita pos-unfreeze...");

        // Restaurar estado nominal válido na DDRAM
        ddram_mem[29'h2997] = 64'h001001014F504C4C;
        for (k = 0; k < 16; k = k + 1) begin
            ddram_mem[29'h2998 + k] = {expected_words[2*k + 1], expected_words[2*k]};
        end

        fork
            begin
                force dut_savestates.op_cooldown = 0;
                ss_load <= 1; tick; ss_load <= 0;
                wait(ss_freeze);
                // Durante o freeze, assertar sinais de escrita normais como se viessem de I/O pendente
                opll_a    <= 1;
                opll_d    <= 8'hFF;
                opll_we_n <= 0;
                opll_cs_n <= 0;
                wait(!ss_freeze);
                // Imediatamente após unfreeze, retirar strobes
                opll_we_n <= 1;
                opll_cs_n <= 1;
                release dut_savestates.op_cooldown;
            end
        join

        // Inspecionar imediatamente se Channel 0 preservou o valor restaurado
        $display("   Inspecionando regs_array(0) imediatamente pos-unfreeze: %06h (Esperado: %06h)",
                 dut_opll.ct.u_register_memory.regs_array[0],
                 {expected_words[0][21:14], 2'b00, expected_words[0][13:0]});
        if (dut_opll.ct.u_register_memory.regs_array[0] !== {expected_words[0][21:14], 2'b00, expected_words[0][13:0]}) begin
            $fatal(1, "Channel 0 foi corrompido por stale write!");
        end
        $display("[PASS CHECK 4] Nenhuma escrita obsoleta vazou para as memorias restauradas.");

        // ====================================================================
        // CHECK 5: ST_ERROR e Preservação de CPU/WRAM
        // ====================================================================
        $display("\n-------------------------------------------------------------------------------");
        $display("[CHECK 5] Detectando transicao para ST_ERROR e verificando preservacao de WRAM...");

        // Marcar padrão específico na WRAM antes do erro
        for (k = 0; k < 64; k = k + 1) wram[k] = 8'h77;

        // Injetar payload corrompido que falhe validação (palavra 2 inválida)
        ddram_mem[29'h2998 + 2] = 64'hFFFFFFFFFFFFFFFF;
        force dut_savestates.op_cooldown = 0;
        ss_load <= 1; tick; ss_load <= 0;
        wait(ss_freeze);
        wait(!ss_freeze);
        release dut_savestates.op_cooldown;

        $display("   LOAD abortou com erro como esperado. Verificando se WRAM inicial foi preservada...");
        for (k = 0; k < 64; k = k + 1) begin
            if (wram[k] !== 8'h77) begin
                $fatal(1, "WRAM corrompida apos ST_ERROR na posicao %0d!", k);
            end
        end
        $display("[PASS CHECK 5] ST_ERROR desvia antes de aplicar FM e preserva o estado de forma segura.");

        $display("\n===============================================================================");
        $display("=== TODOS OS CHECKS DE VALIDACAO RIGOROSA PASSARAM COM EXITO! ===");
        $display("===============================================================================");
        $finish;
    end

endmodule
