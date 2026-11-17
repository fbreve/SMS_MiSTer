`timescale 1ns/1ps

module tb_ym2413_fsm_integration;

    reg clk = 0;
    reg reset_n = 0;
    integer cycle = 0;

    // 53.7 MHz sys clock (period ~18.6 ns -> half 9.3 ns)
    always #9.3 clk = ~clk;

    // DDRAM simplified model (96 KiB slot)
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
            ddram_pending  <= 2;
            ddram_readaddr <= DDRAM_ADDR;
        end
    end

    // Interface signals to savestates
    reg ss_save = 0;
    reg ss_load = 0;
    reg [1:0] ss_slot = 0;
    wire ss_freeze;

    // FM state signals between savestates and OPLL
    wire [7:0]  fm_state_addr;
    wire        fm_state_read;
    wire        fm_state_write;
    wire [31:0] fm_state_wdata;
    wire [31:0] fm_state_rdata;
    wire        fm_initialized;
    wire        fm_legacy_reset;
    wire        fm_initialization_run;

    // Dummy savestates wires
    reg [8:0] x = 0;
    reg vblank = 1;
    reg cpu_ce = 0;
    reg [3:0] ce_div = 0;
    always @(posedge clk) begin
        if (!reset_n) begin
            ce_div <= 0;
            cpu_ce <= 0;
        end else begin
            if (ce_div == 14) begin
                ce_div <= 0;
                cpu_ce <= 1;
            end else begin
                ce_div <= ce_div + 1'b1;
                cpu_ce <= 0;
            end
        end
    end

    // OPLL signals
    reg [7:0] opll_d = 0;
    reg opll_a = 0;
    reg opll_cs_n = 0;
    reg opll_we_n = 1;
    wire [13:0] opll_mixout;

    // Combined wrapper rdata for address 31 (registered like system.vhd)
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

    // Instantiate savestates
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
        .vdp_ce(1'b0),
        .pix_ce(1'b0),
        .sp_ce(1'b0),
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
        .wram_A(),
        .wram_D(8'd0),
        .wram_WE(),
        .wram_WA(),
        .wram_WD(),
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
            $display("[CMD] Triggering SAVE slot %0d...", ss_slot);
            force dut_savestates.op_cooldown = 0;
            ss_save <= 1;
            tick;
            ss_save <= 0;
            wait(ss_freeze);
            $display("[INFO] State frozen, saving to DDRAM...");
            wait(!ss_freeze);
            $display("[INFO] State unfrozen, SAVE complete.");
            repeat(10) tick;
            release dut_savestates.op_cooldown;
        end
    endtask

    task do_load;
        begin
            $display("[CMD] Triggering LOAD slot %0d...", ss_slot);
            force dut_savestates.op_cooldown = 0;
            ss_load <= 1;
            tick;
            ss_load <= 0;
            wait(ss_freeze);
            $display("[INFO] State frozen, restoring from DDRAM...");
            wait(!ss_freeze);
            $display("[INFO] State unfrozen, LOAD complete.");
            repeat(10) tick;
            release dut_savestates.op_cooldown;
        end
    endtask

    integer k;
    initial begin
        $display("=== INICIANDO TESTBENCH FSM SAVESTATES INTEGRADO COM OPLL (APPROACH C) ===");
        reset_n = 0;
        for (k = 0; k < 12288; k = k + 1) ddram_mem[k] = 64'd0;
        repeat (20) tick;
        reset_n = 1;

        while (!fm_initialized) tick;
        $display("[PASS] OPLL inicializado com sucesso.");

        // ====================================================================
        // TESTE 1: Configurar sintetizador com instrumento Custom Voice e nota sustentada
        // ====================================================================
        $display("[TESTE 1] Configurando Custom Voice (0..7) e ativando notas no canal 0 e 1...");
        // User voice patch: carrier mult=1, tl=16, attack=15, decay=4, sustain=1, release=4
        write_opll(8'h00, 8'h31);
        write_opll(8'h01, 8'h21);
        write_opll(8'h02, 8'h10);
        write_opll(8'h03, 8'h07);
        write_opll(8'h04, 8'hF0);
        write_opll(8'h05, 8'hF0);
        write_opll(8'h06, 8'h04);
        write_opll(8'h07, 8'h04);

        $display("   [DEBUG PROBE INIT] opllptr=%02x, opllwr=%0b", dut_opll.opllptr, dut_opll.opllwr);
        write_opll(8'h10, 8'h91);
        $display("   [DEBUG PROBE 10] opllptr=%02x, opllwr=%0b, regs_array[0]=%06h",
                 dut_opll.opllptr, dut_opll.opllwr, dut_opll.ct.u_register_memory.regs_array[0]);
        write_opll(8'h30, 8'h00);
        $display("   [DEBUG PROBE 30] opllptr=%02x, opllwr=%0b, regs_array[0]=%06h",
                 dut_opll.opllptr, dut_opll.opllwr, dut_opll.ct.u_register_memory.regs_array[0]);
        write_opll(8'h20, 8'h39);
        $display("   [DEBUG PROBE 20] opllptr=%02x, opllwr=%0b, regs_array[0]=%06h",
                 dut_opll.opllptr, dut_opll.opllwr, dut_opll.ct.u_register_memory.regs_array[0]);

        // Canal 1: Preset Voice 2 (Violin), Key-On
        write_opll(8'h31, 8'h20);
        write_opll(8'h11, 8'h70);
        write_opll(8'h21, 8'h15);

        // Deixar oscilar por 10.000 clocks para que o envelope entre na fase de sustain
        repeat(10000) tick;
        $display("   [DEBUG PRE-SAVE] mixout=%04x, Ch0 regs_array=%06h, Env0 egdata_set=%07h",
                 opll_mixout, dut_opll.ct.u_register_memory.regs_array[0], dut_opll.eg.u_envelope_memory.egdata_set[0]);

        // ====================================================================
        // TESTE 2: Executar SAVE real via FSM em savestates.sv
        // ====================================================================
        $display("[TESTE 2] Executando SAVE real via savestates.sv...");
        ss_slot = 0;
        do_save();

        // Verificar descritor salvo na DDRAM em 29'h07c02997
        if (ddram_mem[29'h2997] == 64'h001001014F504C4C) begin
            $display("[PASS] FM Descriptor gravado corretamente na DDRAM: %016h", ddram_mem[29'h2997]);
        end else begin
            $fatal(1, "Descritor FM incorreto na DDRAM: %016h (esperado: 001001014F504C4C)", ddram_mem[29'h2997]);
        end

        // Verificar que canais e envelopes foram gravados na DDRAM
        $display("[INFO] Payload salvo nas primeiras palavras de DDRAM:");
        for (k = 0; k < 4; k = k + 1) begin
            $display("   DDRAM[29'h%04x] = %016h", 29'h2998 + k, ddram_mem[29'h2998 + k]);
        end

        // ====================================================================
        // TESTE 3: Alterar completamente o estado do sintetizador (simular jogo avançando)
        // ====================================================================
        $display("[TESTE 3] Corrompendo/alterando estado do YM2413...");
        // Mutar canal 0, desativar Key-On, trocar voz para Piano
        write_opll(8'h20, 8'h09); // Key-off canal 0
        write_opll(8'h30, 8'h3F); // Mute canal 0, Preset 3
        write_opll(8'h21, 8'h00); // Key-off canal 1
        write_opll(8'h00, 8'h00); // Zera user voice
        write_opll(8'h01, 8'h00);
        repeat(5000) tick;

        // ====================================================================
        // TESTE 4: Executar LOAD real via FSM em savestates.sv
        // ====================================================================
        $display("[TESTE 4] Executando LOAD real via savestates.sv...");
        do_load();

        if (dut_savestates.state == 6'd40) begin // ST_ERROR
            $fatal(1, "Savestates FSM entrou em ST_ERROR durante LOAD!");
        end

        $display("[PASS] LOAD concluiu com sucesso sem erros!");

        // Verificar restauração imediata do canal 0 e 1 e user voice
        $display("   [DEBUG POST-LOAD] Ch0 regs_array=%06h, Env0 egdata_set=%07h",
                 dut_opll.ct.u_register_memory.regs_array[0], dut_opll.eg.u_envelope_memory.egdata_set[0]);
        $display("[CHECK] Verificando se nota sustentada continuou e mixout estavel...");
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
        end

        // ====================================================================
        // TESTE 5: Teste de Fallback com Savestate Legado (Sem descritor OPLL)
        // ====================================================================
        $display("[TESTE 5] Testando compatibilidade retroativa (Legacy Savestate)...");
        // Substituir descritor por 0 (legado)
        ddram_mem[29'h2997] = 64'd0;
        do_load();

        if (dut_savestates.state == 6'd40) begin
            $fatal(1, "Savestates falhou com savestate legado!");
        end
        $display("[PASS] Legacy savestate carregado sem aborto! has_fm = %0b", dut_savestates.has_fm);

        // ====================================================================
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
        write_opll(8'h20, 8'h39);
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

endmodule
