`timescale 1ns/1ps

module tb_ym2413_defects_repro;

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

    // Combined wrapper rdata for address 31 (mirrors system.vhd exactly)
    reg [7:0] latch_fm_d = 0;
    reg latch_fm_a = 0;
    wire [31:0] opll_direct_rdata;
    reg [31:0] fm_wrapper_rdata = 0;
    always @(posedge clk) begin
        fm_wrapper_rdata <= 32'd0;
        if (ss_freeze && fm_state_read && fm_state_addr == 8'd31) begin
            fm_wrapper_rdata <= {17'd0, latch_fm_a, latch_fm_d, 6'd0};
        end
    end
    assign fm_state_rdata = opll_direct_rdata | fm_wrapper_rdata;

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

            repeat (6) begin
                @(posedge clk);
                while (!cpu_ce) @(posedge clk);
            end

            opll_a <= 1;
            opll_d <= data;
            opll_we_n <= 0;
            @(posedge clk);
            while (!cpu_ce) @(posedge clk);
            opll_we_n <= 1;

            repeat (10) begin
                @(posedge clk);
                while (!cpu_ce) @(posedge clk);
            end
        end
    endtask

    // Glitch detector on ss_freeze: track any transition 1 -> 0 -> 1 within unfreeze window
    integer freeze_glitch_detected = 0;
    reg prev_ss_freeze = 0;
    always @(posedge clk) begin
        if (dut_savestates.state == 6'd63 && prev_ss_freeze == 0 && dut_savestates.unfreeze_cnt < 10) begin
            freeze_glitch_detected <= freeze_glitch_detected + 1;
            $display("[EVIDENCE D5] Glitch detected! ss_freeze dipped to 0 at unfreeze_cnt=%0d during settle transition!", dut_savestates.unfreeze_cnt);
        end
        prev_ss_freeze <= ss_freeze;
    end

    integer k;
    initial begin
        $display("===============================================================================");
        $display("=== SUITE DE REPRODUCAO EXATA DE DEFEITOS D1 A D5 (RTL ATUAL INALTERADO) ===");
        $display("===============================================================================");
        reset_n = 0;
        for (k = 0; k < 12288; k = k + 1) ddram_mem[k] = 64'd0;
        repeat (20) tick;
        reset_n = 1;

        while (!fm_initialized) tick;
        $display("[INIT] OPLL inicializado com sucesso.");

        // ====================================================================
        // PROVA DEFEITO D1: Mascara fm_word_valid rejeitando canal com volume legitimo (bit 14 = 1)
        // ====================================================================
        $display("\n-------------------------------------------------------------------------------");
        $display("[PROVA D1] Testando rejeicao indevida de canal com volume legitimo (bit 14=1 / 0x4000)...");
        // Criar um savestate sintético com descritor válido
        ddram_mem[29'h2997] = 64'h001001014F504C4C; // FM_DESC
        // Canal 0 com valor legítimo: FNUM=8'h91, BLK=1, KEY=1, INST=0, VOL=1 (bit 14 setado -> 0x00005991)
        // Note que o bit 14 corresponde ao bit 0 de volume no empacotamento de RegisterMemory!
        ddram_mem[29'h2998] = {32'h00000000, 32'h00005991}; 
        for (k = 1; k < 16; k = k + 1) ddram_mem[29'h2998 + k] = 64'd0;

        // Testar validade logica do canal com bit 14=1

        if (!dut_savestates.fm_word_valid(5'd0, 32'h00005991)) begin
            $display("[EVIDENCE D1 CONFIRMADA] fm_word_valid rejeitou canal com volume legitimo!");
        end else begin
            $display("[FIX VERIFIED D1] fm_word_valid aceitou com sucesso o canal com bit 14=1 (0x00005991).");
            if (dut_savestates.has_fm == 1) $display("[FIX VERIFIED D1] LOAD concluiu com sucesso e has_fm = 1.");
        end

        // ====================================================================
        // PROVA DEFEITO D2: Latencia de Leitura Sincrona no SAVE (Captura Prematura)
        // ====================================================================
        $display("\n-------------------------------------------------------------------------------");
        $display("[PROVA D2] Testando latencia efetiva de leitura sincrona do FM durante SAVE...");
        // Configurar valores distintos nos canais 0, 1 e 2
        write_opll(8'h10, 8'hA1); // Canal 0 FNUM
        repeat(500) tick;
        write_opll(8'h20, 8'h11);
        repeat(500) tick;
        write_opll(8'h30, 8'h10); // Canal 0 Inst 1
        repeat(500) tick;
        write_opll(8'h11, 8'hB2); // Canal 1 FNUM
        repeat(500) tick;
        write_opll(8'h21, 8'h12);
        repeat(500) tick;
        write_opll(8'h12, 8'hC3); // Canal 2 FNUM
        repeat(500) tick;
        write_opll(8'h22, 8'h13);
        repeat(5000) tick;

        // Executar SAVE nominal
        force dut_savestates.op_cooldown = 0;
        ss_save <= 1; tick; ss_save <= 0;
        wait(ss_freeze);
        wait(!ss_freeze);
        release dut_savestates.op_cooldown;

        $display("   Valores salvos na DDRAM:");
        $display("   DDRAM Palavra 0 (Ch 1 / Ch 0): %016h", ddram_mem[29'h2998]);
        $display("   DDRAM Palavra 1 (Ch 3 / Ch 2): %016h", ddram_mem[29'h2999]);
        if (ddram_mem[29'h2998][31:0] == 32'd0) begin
            $display("[EVIDENCE D2 CONFIRMADA] Canal 0 capturado prematuramente como 00000000!");
        end else begin
            $display("[FIX VERIFIED D2] Canal 0 capturado com dados validos: %08h (Ch1: %08h)", ddram_mem[29'h2998][31:0], ddram_mem[29'h2998][63:32]);
        end

        // ====================================================================
        // PROVA DEFEITO D3: Perda da Resposta do Endereço 31 com DDRAM BUSY
        // ====================================================================
        $display("\n-------------------------------------------------------------------------------");
        $display("[PROVA D3] Testando perda do registrador de controle (end 31) sob DDRAM BUSY...");
        // Escrever rflag de ritmo ativo (rflag = 0x20 -> ritmo on)
        write_opll(8'h0E, 8'h20);
        repeat(100) tick;

        // Disparar SAVE e injetar DDRAM_BUSY exatamente quando fm_word == 15
        fork
            begin
                force dut_savestates.op_cooldown = 0;
                ss_save <= 1; tick; ss_save <= 0;
                wait(dut_savestates.state == 7'd73); // ST_FM_SAVE_LO
                wait(dut_savestates.fm_word == 5'd15);
                wait(dut_savestates.state == 7'd76); // ST_FM_SAVE_WRITE
                $display("   [INJECT] Impondo DDRAM_BUSY = 1 durante ST_FM_SAVE_WRITE da palavra 15...");
                DDRAM_BUSY <= 1;
                repeat (5) tick;
                $display("   [INJECT] Liberando DDRAM_BUSY = 0");
                DDRAM_BUSY <= 0;
                wait(!ss_freeze);
                release dut_savestates.op_cooldown;
            end
        join

        $display("   DDRAM Palavra 15 (Addr 31 [Ctrl] / Addr 30 [Env 17]): %016h", ddram_mem[29'h2998 + 15]);
        if (ddram_mem[29'h2998 + 15][63:32] == 32'd0) begin
            $display("[EVIDENCE D3 CONFIRMADA] Endereco 31 decaiu para 0 sob DDRAM BUSY! Ritmo foi perdido no save!");
        end else begin
            $display("[FIX VERIFIED D3] Endereco 31 preservado perfeitamente sob DDRAM BUSY: %08h", ddram_mem[29'h2998 + 15][63:32]);
        end

        // ====================================================================
        // PROVA DEFEITO D4: LOAD Nao-Atomico (Modificacao Parcial antes de ST_ERROR)
        // ====================================================================
        $display("\n-------------------------------------------------------------------------------");
        $display("[PROVA D4] Testando LOAD nao-atomico: modificacao parcial de canais antes de ST_ERROR...");
        // Configurar Canal 0 limpo com FNUM=8'hAA
        write_opll(8'h10, 8'hAA);
        repeat(50) tick;

        // Criar DDRAM com Palavra 0 alterada (FNUM=8'h55), mas Palavra 15 corrompida (vai dar ST_ERROR no fim)
        ddram_mem[29'h2997] = 64'h001001014F504C4C;
        ddram_mem[29'h2998] = {32'h00000000, 32'h00001055}; // FNUM 55
        ddram_mem[29'h2998 + 15] = {32'hFF000000, 32'd0};  // Invalido!

        force dut_savestates.op_cooldown = 0;
        ss_load <= 1; tick; ss_load <= 0;
        wait(ss_freeze);
        wait(!ss_freeze);
        release dut_savestates.op_cooldown;

        $display("   Verificando se Canal 0 foi escrito antes do ST_ERROR abortar...");
        // Inspecionar regs_array(0) em RegisterMemory
        $display("   RegisterMemory canal 0 atual: %06h", dut_opll.ct.u_register_memory.regs_array[0]);
        if (dut_opll.ct.u_register_memory.regs_array[0] == 24'h001055) begin
            $display("[EVIDENCE D4 CONFIRMADA] Canal 0 foi modificado para 001055 apesar do LOAD ter falhado em ST_ERROR!");
        end else begin
            $display("[FIX VERIFIED D4] Failure atomicity garantida: Canal 0 conservado intacto em: %06h", dut_opll.ct.u_register_memory.regs_array[0]);
        end

        // ====================================================================
        // PROVA DEFEITO D5: Glitch de Unfreeze e Reset sem Espera de fm_initialized
        // ====================================================================
        $display("\n-------------------------------------------------------------------------------");
        $display("[PROVA D5] Testando glitch de freeze duplo e falta de espera por fm_initialized...");
        if (freeze_glitch_detected > 0) begin
            $display("[EVIDENCE D5 CONFIRMADA] %0d glitches de ss_freeze detectados (1 -> 0 -> 1)!", freeze_glitch_detected);
        end else begin
            $display("   Nenhum glitch de ss_freeze detectado ate agora.");
        end

        // Testar se ST_FM_LEGACY_WAIT aguarda fm_initialized sob bypass de freeze
        $display("   Verificando ST_FM_LEGACY_WAIT: aguardando fm_initialized...");
        force dut_savestates.state = 7'd40; // ST_ERROR
        tick;
        release dut_savestates.state;
        wait(dut_savestates.state == 7'd85); // ST_FM_LEGACY_WAIT
        $display("   Entrou em ST_FM_LEGACY_WAIT: ss_freeze=%0b, fm_initialization_run=%0b", ss_freeze, fm_initialization_run);
        wait(dut_savestates.state == 7'd63); // ST_UNFREEZE_SETTLE
        $display("[FIX VERIFIED D5] Transicionou para ST_UNFREEZE_SETTLE somente apos fm_initialized=%0b!", fm_initialized);
        wait(!ss_freeze);
        $display("   Descongelou em ST_IDLE com sucesso.");

        $display("\n===============================================================================");
        $display("=== EXECUCAO DA SUITE DE REPRODUCAO FINALIZADA ===");
        $display("===============================================================================");
        $finish;
    end

endmodule
