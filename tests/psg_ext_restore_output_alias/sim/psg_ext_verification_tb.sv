`timescale 1ns/1ps
module psg_ext_verification_tb;
    reg clk = 0;
    reg reset_n = 0;
    reg ss_save = 0;
    reg ss_load = 0;
    reg [1:0] ss_slot = 0;
    reg ss_bios_mode = 0;
    reg [31:0] ss_game_id = 32'h12345678;
    reg vblank = 1;
    reg [8:0] x = 0;
    reg [229:0] z80_reg = 0;
    reg z80_m1_n = 0;
    reg z80_mreq_n = 0;
    reg [1:0] z80_iset = 0;
    reg cpu_ce = 0;
    reg vdp_ce = 0;
    reg pix_ce = 0;
    reg sp_ce = 0;
    reg [127:0] vdp_regs = 0;
    reg [383:0] cram_out = 0;
    reg [7:0] vram_D = 0;
    reg [55:0] psg_out = 0;
    reg [95:0] psg_ext_out = 0;
    reg [95:0] psg2_ext_out = 0;
    reg [3:0] psg_div_out = 0;
    reg [10:0] audio_control_out = 0;
    reg audio_quiescent = 1;
    reg audio_phase_out = 0;
    reg [63:0] mapper_out = 0;
    reg [95:0] evolution_out = 0;
    reg [63:0] eeprom_out = 0;
    reg [7:0] wram_D = 0;
    reg [7:0] nvram_D = 0;
    reg systeme = 0;
    reg [127:0] vdp2_regs = 0;
    reg [383:0] cram2_out = 0;
    reg [7:0] vram2_D = 0;
    reg [55:0] psg2_out = 0;
    reg [31:0] io_out = 32'h0;
    reg [21:0] video_state_out = 0;

    reg [63:0] DDRAM_DOUT = 0;
    reg DDRAM_DOUT_READY = 0;
    reg DDRAM_BUSY = 0;

    wire ss_freeze_a, ss_freeze_b;
    wire [95:0] psg_ext_in_a, psg_ext_in_b;
    wire [95:0] psg2_ext_in_a, psg2_ext_in_b;
    wire audio_ext_set_a, audio_ext_set_b;
    wire [28:0] DDRAM_ADDR_a, DDRAM_ADDR_b;
    wire [63:0] DDRAM_DIN_a, DDRAM_DIN_b;
    wire [7:0] DDRAM_BE_a, DDRAM_BE_b;
    wire DDRAM_WE_a, DDRAM_WE_b;
    wire DDRAM_RD_a, DDRAM_RD_b;

    savestates_baseline a (
        .clk(clk), .reset_n(reset_n), .ss_save(ss_save), .ss_load(ss_load),
        .ss_slot(ss_slot), .ss_bios_mode(ss_bios_mode), .ss_game_id(ss_game_id),
        .ss_freeze(ss_freeze_a), .vblank(vblank), .x(x),
        .z80_reg(z80_reg), .z80_dir(), .z80_set(), .z80_m1_n(z80_m1_n),
        .z80_mreq_n(z80_mreq_n), .z80_iset(z80_iset),
        .cpu_ce(cpu_ce), .vdp_ce(vdp_ce), .pix_ce(pix_ce), .sp_ce(sp_ce),
        .vdp_regs(vdp_regs), .vdp_regs_in(), .vdp_regs_set(),
        .cram_out(cram_out), .cram_A(), .cram_D(), .cram_wr(),
        .vram_en(), .vram_A(), .vram_D(vram_D), .vram_WE(), .vram_WA(), .vram_WD(),
        .psg_out(psg_out), .psg_in(), .psg_set(),
        .psg_ext_out(psg_ext_out), .psg2_ext_out(psg2_ext_out),
        .psg_ext_in(psg_ext_in_a), .psg2_ext_in(psg2_ext_in_a),
        .psg_div_out(psg_div_out), .psg_div_in(),
        .audio_control_out(audio_control_out), .audio_control_in(),
        .audio_quiescent(audio_quiescent), .audio_phase_out(audio_phase_out),
        .audio_phase_in(), .audio_ext_set(audio_ext_set_a), .audio_phase_set(),
        .mapper_out(mapper_out), .mapper_in(), .mapper_set(),
        .evolution_out(evolution_out), .evolution_in(), .evolution_set(),
        .eeprom_out(eeprom_out), .eeprom_in(), .eeprom_set(),
        .wram_A(), .wram_D(wram_D), .wram_WE(), .wram_WA(), .wram_WD(),
        .nvram_A(), .nvram_D(nvram_D), .nvram_WE(), .nvram_WA(), .nvram_WD(),
        .systeme(systeme),
        .vdp2_regs(vdp2_regs), .vdp2_regs_in(), .vdp2_regs_set(),
        .cram2_out(cram2_out), .cram2_A(), .cram2_D(), .cram2_wr(),
        .vram2_en(), .vram2_A(), .vram2_D(vram2_D), .vram2_WE(), .vram2_WA(), .vram2_WD(),
        .psg2_out(psg2_out), .psg2_in(), .psg2_set(),
        .io_out(io_out), .io_in(), .io_set(),
        .video_state_out(video_state_out), .video_state_in(), .video_state_set(),
        .DDRAM_ADDR(DDRAM_ADDR_a), .DDRAM_DIN(DDRAM_DIN_a), .DDRAM_BE(DDRAM_BE_a),
        .DDRAM_WE(DDRAM_WE_a), .DDRAM_DOUT(DDRAM_DOUT), .DDRAM_DOUT_READY(DDRAM_DOUT_READY),
        .DDRAM_RD(DDRAM_RD_a), .DDRAM_BURSTCNT(), .DDRAM_BUSY(DDRAM_BUSY)
    );

    savestates_candidate b (
        .clk(clk), .reset_n(reset_n), .ss_save(ss_save), .ss_load(ss_load),
        .ss_slot(ss_slot), .ss_bios_mode(ss_bios_mode), .ss_game_id(ss_game_id),
        .ss_freeze(ss_freeze_b), .vblank(vblank), .x(x),
        .z80_reg(z80_reg), .z80_dir(), .z80_set(), .z80_m1_n(z80_m1_n),
        .z80_mreq_n(z80_mreq_n), .z80_iset(z80_iset),
        .cpu_ce(cpu_ce), .vdp_ce(vdp_ce), .pix_ce(pix_ce), .sp_ce(sp_ce),
        .vdp_regs(vdp_regs), .vdp_regs_in(), .vdp_regs_set(),
        .cram_out(cram_out), .cram_A(), .cram_D(), .cram_wr(),
        .vram_en(), .vram_A(), .vram_D(vram_D), .vram_WE(), .vram_WA(), .vram_WD(),
        .psg_out(psg_out), .psg_in(), .psg_set(),
        .psg_ext_out(psg_ext_out), .psg2_ext_out(psg2_ext_out),
        .psg_ext_in(psg_ext_in_b), .psg2_ext_in(psg2_ext_in_b),
        .psg_div_out(psg_div_out), .psg_div_in(),
        .audio_control_out(audio_control_out), .audio_control_in(),
        .audio_quiescent(audio_quiescent), .audio_phase_out(audio_phase_out),
        .audio_phase_in(), .audio_ext_set(audio_ext_set_b), .audio_phase_set(),
        .mapper_out(mapper_out), .mapper_in(), .mapper_set(),
        .evolution_out(evolution_out), .evolution_in(), .evolution_set(),
        .eeprom_out(eeprom_out), .eeprom_in(), .eeprom_set(),
        .wram_A(), .wram_D(wram_D), .wram_WE(), .wram_WA(), .wram_WD(),
        .nvram_A(), .nvram_D(nvram_D), .nvram_WE(), .nvram_WA(), .nvram_WD(),
        .systeme(systeme),
        .vdp2_regs(vdp2_regs), .vdp2_regs_in(), .vdp2_regs_set(),
        .cram2_out(cram2_out), .cram2_A(), .cram2_D(), .cram2_wr(),
        .vram2_en(), .vram2_A(), .vram2_D(vram2_D), .vram2_WE(), .vram2_WA(), .vram2_WD(),
        .psg2_out(psg2_out), .psg2_in(), .psg2_set(),
        .io_out(io_out), .io_in(), .io_set(),
        .video_state_out(video_state_out), .video_state_in(), .video_state_set(),
        .DDRAM_ADDR(DDRAM_ADDR_b), .DDRAM_DIN(DDRAM_DIN_b), .DDRAM_BE(DDRAM_BE_b),
        .DDRAM_WE(DDRAM_WE_b), .DDRAM_DOUT(DDRAM_DOUT), .DDRAM_DOUT_READY(DDRAM_DOUT_READY),
        .DDRAM_RD(DDRAM_RD_b), .DDRAM_BURSTCNT(), .DDRAM_BUSY(DDRAM_BUSY)
    );

    always #5 clk = ~clk;

    // Simulated DDRAM memory
    reg [63:0] memory [0:98303];
    reg [28:0] ra;
    integer pending = 0;
    integer cycles = 0;

    // Real-time differential monitor
    integer strobe_count = 0;
    integer mismatches = 0;

    always @(negedge clk) begin
        cycles <= cycles + 1;
        cpu_ce <= (cycles % 15 == 0);
        vdp_ce <= (cycles % 10 == 0);
        pix_ce <= (cycles % 10 == 0);
        sp_ce  <= (cycles % 5 == 0);

        #1;
        if (reset_n) begin
            // 1. Both audio_ext_set strobes MUST be cycle-identical
            if (audio_ext_set_a !== audio_ext_set_b) begin
                $display("ERROR: audio_ext_set mismatch at cycle %0d: baseline=%b candidate=%b", cycles, audio_ext_set_a, audio_ext_set_b);
                mismatches = mismatches + 1;
            end

            // 2. Exact match at strobe cycle
            if (audio_ext_set_a) begin
                strobe_count = strobe_count + 1;
                if (psg_ext_in_a !== psg_ext_in_b) begin
                    $display("ERROR: psg_ext_in mismatch during strobe at cycle %0d! baseline=%h candidate=%h", cycles, psg_ext_in_a, psg_ext_in_b);
                    mismatches = mismatches + 1;
                end else begin
                    $display("PASS: Strobe %0d captured psg_ext_in=%h identically!", strobe_count, psg_ext_in_b);
                end
            end

            // 3. PSG2 ext in must remain 100% cycle-identical everywhere
            if (psg2_ext_in_a !== psg2_ext_in_b) begin
                $display("ERROR: psg2_ext_in mismatch at cycle %0d: a=%h b=%h", cycles, psg2_ext_in_a, psg2_ext_in_b);
                mismatches = mismatches + 1;
            end

            // 4. Memory writes and reads must match
            if (DDRAM_WE_a !== DDRAM_WE_b) $fatal(1, "DDRAM_WE mismatch");
            if (DDRAM_RD_a !== DDRAM_RD_b) $fatal(1, "DDRAM_RD mismatch");
            if (DDRAM_WE_a && (DDRAM_ADDR_a !== DDRAM_ADDR_b || DDRAM_DIN_a !== DDRAM_DIN_b)) begin
                $display("ERROR: DDRAM write mismatch at cycle %0d: A=(%h, %h) B=(%h, %h)", cycles, DDRAM_ADDR_a, DDRAM_DIN_a, DDRAM_ADDR_b, DDRAM_DIN_b);
                mismatches = mismatches + 1;
            end
        end
    end

    always @(posedge clk) begin
        DDRAM_DOUT_READY <= 0;
        if (pending > 0) begin
            pending <= pending - 1;
            if (pending == 1) begin
                DDRAM_DOUT <= memory[ra - 29'h07C00000];
                DDRAM_DOUT_READY <= 1;
            end
        end
        if (DDRAM_WE_a && !DDRAM_BUSY) begin
            for (integer b = 0; b < 8; b = b + 1) begin
                if (DDRAM_BE_a[b]) memory[DDRAM_ADDR_a - 29'h07C00000][b*8 +: 8] <= DDRAM_DIN_a[b*8 +: 8];
            end
        end
        if (DDRAM_RD_a && !DDRAM_BUSY) begin
            ra <= DDRAM_ADDR_a;
            pending <= 3;
        end
    end

    task tick;
        begin
            @(negedge clk); #2;
        end
    endtask

    integer op = 0;
    task run_save_load(input [95:0] psg_val, input [95:0] psg2_val);
        begin
            psg_ext_out = psg_val;
            psg2_ext_out = psg2_val;
            force a.op_cooldown = 0; force b.op_cooldown = 0;
            // Trigger Save
            ss_save = 1; tick; ss_save = 0;
            wait(ss_freeze_a);
            wait(!ss_freeze_a);
            repeat (10) tick;

            // Mutate live inputs during execution to prove isolation
            psg_ext_out = ~psg_val;
            psg2_ext_out = ~psg2_val;
            repeat (30) tick;

            // Trigger Load
            ss_load = 1; tick; ss_load = 0;
            wait(ss_freeze_a);
            wait(!ss_freeze_a);
            repeat (20) tick;
            release a.op_cooldown; release b.op_cooldown;
            op = op + 1;
            $display("SUCCESS: Test %0d (Save/Load with psg_ext=0x%024h) completed with exact bit equivalence.", op, psg_val);
        end
    endtask

    initial begin
        reset_n = 0; repeat (6) tick; reset_n = 1;
        vblank = 1; x = 0; z80_m1_n = 0; z80_mreq_n = 0; audio_quiescent = 1;

        $display("=== INICIANDO BATERIA DE TESTES DIFERENCIAIS: psg_ext_in ===");

        // Test 1: Standard save and load with known PSG extended payload
        run_save_load(96'hA1B2C3D4E5F60718293A4B5C, 96'hFEDCBA987654321012345678);

        // Test 2: Consecutivos Save e Load com padrões complexos de LFSR e contadores
        run_save_load(96'h5555AAAA3333CCCC0F0F00FF, 96'hA5A55A5AA5A55A5A5A5AA5A5);
        run_save_load(96'hFFFFFFFFFFFFFFFFFFFFFFFF, 96'h000000000000000000000000);
        run_save_load(96'h123456789ABCDEF001234567, 96'h76543210FEDCBA9889ABCDEF);

        // Test 3: System E habilitado (PSG2 simultâneo)
        systeme = 1;
        run_save_load(96'h112233445566778899AABBCC, 96'h00FFEECCAABB998877665544);
        systeme = 0;

        // Test 4: Savestate Legado (sem extensão de áudio, has_audio_ext = 0)
        $display("\n--- Test 6: Savestate de formato legado ---");
        // Em formato legado, a palavra 0 do slot tem OLD_SS_WORDS (29'h00004000)
        memory[0] = {32'h00004000, 32'h0}; // OLD_SS_WORDS
        memory[1] = {32'h0, 32'h534D5353}; // MAGIC
        force a.op_cooldown = 0; force b.op_cooldown = 0;
        ss_load = 1; tick; ss_load = 0;
        wait(ss_freeze_a);
        wait(!ss_freeze_a);
        repeat (20) tick;
        release a.op_cooldown; release b.op_cooldown;
        $display("SUCCESS: Test 6 (Savestate legado) completado.");

        repeat (50) tick;
        $display("\n========================================================");
        $display("RESULTADO FINAL: %0d strobes verificados com sucesso.", strobe_count);
        $display("Mismatches encontrados: %0d", mismatches);
        $display("========================================================");
        if (mismatches == 0 && strobe_count >= 5) begin
            $display(">>> TESTBENCH APROVADO: EQUIVALENCIA TOTAL DEMONSTRADA <<<");
        end else begin
            $display(">>> TESTBENCH REPROVADO <<<");
            $fatal(1, "Falha na verificacao diferencial!");
        end
        $finish;
    end

endmodule
