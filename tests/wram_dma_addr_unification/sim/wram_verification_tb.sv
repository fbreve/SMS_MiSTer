`timescale 1ns/1ps
module wram_verification_tb;
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

    // Simulated WRAM memories
    // Baseline model memory and Candidate model memory
    reg [7:0] wram_sim_a [0:16383];
    reg [7:0] wram_sim_b [0:16383];

    // DUT baseline signals
    wire ss_freeze_a;
    wire [13:0] wram_A_a, wram_WA_a;
    wire [7:0]  wram_WD_a;
    wire        wram_WE_a;
    wire [28:0] DDRAM_ADDR_a;
    wire [63:0] DDRAM_DIN_a;
    wire [7:0]  DDRAM_BE_a;
    wire        DDRAM_WE_a;
    wire        DDRAM_RD_a;
    reg  [7:0]  wram_D_a;

    // DUT candidate signals
    wire ss_freeze_b;
    wire [13:0] wram_A_b, wram_WA_b;
    wire [7:0]  wram_WD_b;
    wire        wram_WE_b;
    wire [28:0] DDRAM_ADDR_b;
    wire [63:0] DDRAM_DIN_b;
    wire [7:0]  DDRAM_BE_b;
    wire        DDRAM_WE_b;
    wire        DDRAM_RD_b;
    reg  [7:0]  wram_D_b;

    // Connect WRAM simulation read ports (registered synchronous RAM read)
    always @(posedge clk) begin
        wram_D_a <= wram_sim_a[wram_A_a];
        wram_D_b <= wram_sim_b[wram_A_b];

        if (wram_WE_a) wram_sim_a[wram_WA_a] <= wram_WD_a;
        if (wram_WE_b) wram_sim_b[wram_WA_b] <= wram_WD_b;
    end

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
        .psg_ext_in(), .psg2_ext_in(),
        .psg_div_out(psg_div_out), .psg_div_in(),
        .audio_control_out(audio_control_out), .audio_control_in(),
        .audio_quiescent(audio_quiescent), .audio_phase_out(audio_phase_out),
        .audio_phase_in(), .audio_ext_set(), .audio_phase_set(),
        .mapper_out(mapper_out), .mapper_in(), .mapper_set(),
        .evolution_out(evolution_out), .evolution_in(), .evolution_set(),
        .eeprom_out(eeprom_out), .eeprom_in(), .eeprom_set(),
        .wram_A(wram_A_a), .wram_D(wram_D_a), .wram_WE(wram_WE_a), .wram_WA(wram_WA_a), .wram_WD(wram_WD_a),
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
        .psg_ext_in(), .psg2_ext_in(),
        .psg_div_out(psg_div_out), .psg_div_in(),
        .audio_control_out(audio_control_out), .audio_control_in(),
        .audio_quiescent(audio_quiescent), .audio_phase_out(audio_phase_out),
        .audio_phase_in(), .audio_ext_set(), .audio_phase_set(),
        .mapper_out(mapper_out), .mapper_in(), .mapper_set(),
        .evolution_out(evolution_out), .evolution_in(), .evolution_set(),
        .eeprom_out(eeprom_out), .eeprom_in(), .eeprom_set(),
        .wram_A(wram_A_b), .wram_D(wram_D_b), .wram_WE(wram_WE_b), .wram_WA(wram_WA_b), .wram_WD(wram_WD_b),
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
    integer mismatches = 0;

    always @(negedge clk) begin
        cycles <= cycles + 1;
        cpu_ce <= (cycles % 15 == 0);
        vdp_ce <= (cycles % 10 == 0);
        pix_ce <= (cycles % 10 == 0);
        sp_ce  <= (cycles % 5 == 0);

        #1;
        if (reset_n) begin
            // 1. Freeze signals must match
            if (ss_freeze_a !== ss_freeze_b) begin
                $display("ERROR: ss_freeze mismatch at cycle %0d", cycles);
                mismatches = mismatches + 1;
            end

            // 2. WRAM read address bus comparison (during SAVE)
            if (wram_A_a !== wram_A_b) begin
                $display("ERROR: wram_A mismatch at cycle %0d: baseline=%h cand=%h", cycles, wram_A_a, wram_A_b);
                mismatches = mismatches + 1;
            end

            // 3. WRAM write address, data and enable (during LOAD)
            if (wram_WE_a !== wram_WE_b) begin
                $display("ERROR: wram_WE mismatch at cycle %0d: baseline=%b cand=%b", cycles, wram_WE_a, wram_WE_b);
                mismatches = mismatches + 1;
            end
            if (wram_WE_a) begin
                if (wram_WA_a !== wram_WA_b) begin
                    $display("ERROR: wram_WA mismatch at cycle %0d: baseline=%h cand=%h", cycles, wram_WA_a, wram_WA_b);
                    mismatches = mismatches + 1;
                end
                if (wram_WD_a !== wram_WD_b) begin
                    $display("ERROR: wram_WD mismatch at cycle %0d: baseline=%h cand=%h", cycles, wram_WD_a, wram_WD_b);
                    mismatches = mismatches + 1;
                end
            end

            // 4. DDRAM bus transactions
            if (DDRAM_WE_a !== DDRAM_WE_b) $fatal(1, "DDRAM_WE mismatch");
            if (DDRAM_RD_a !== DDRAM_RD_b) $fatal(1, "DDRAM_RD mismatch");
            if (DDRAM_WE_a && (DDRAM_ADDR_a !== DDRAM_ADDR_b || DDRAM_DIN_a !== DDRAM_DIN_b)) begin
                $display("ERROR: DDRAM write mismatch at cycle %0d", cycles);
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

    // Helper: Initialize WRAM with pseudorandom pattern
    task init_wram(input integer size, input [7:0] seed);
        integer i;
        begin
            for (i = 0; i < size; i = i + 1) begin
                wram_sim_a[i] = (seed + i * 17) & 8'hFF;
                wram_sim_b[i] = (seed + i * 17) & 8'hFF;
            end
        end
    endtask

    // Helper: Verify WRAM contents byte-by-byte
    task verify_wram(input integer size, input [7:0] expected_seed);
        integer i;
        integer err_cnt;
        reg [7:0] exp_val;
        begin
            err_cnt = 0;
            for (i = 0; i < size; i = i + 1) begin
                exp_val = (expected_seed + i * 17) & 8'hFF;
                if (wram_sim_a[i] !== exp_val || wram_sim_b[i] !== exp_val) begin
                    if (err_cnt < 5) begin
                        $display("ERROR: WRAM data mismatch at byte %0d! exp=%h base=%h cand=%h", i, exp_val, wram_sim_a[i], wram_sim_b[i]);
                    end
                    err_cnt = err_cnt + 1;
                end
            end
            if (err_cnt > 0) begin
                $display("FAIL: %0d byte mismatches detected in WRAM!", err_cnt);
                mismatches = mismatches + err_cnt;
            end else begin
                $display("PASS: All %0d bytes verified byte-by-byte with 100%% data integrity.", size);
            end
        end
    endtask

    integer op = 0;
    task run_wram_test(input integer size, input [7:0] pattern_seed);
        integer i;
        begin
            init_wram(size, pattern_seed);
            force a.op_cooldown = 0; force b.op_cooldown = 0;
            // 1. SAVE
            ss_save = 1; tick; ss_save = 0;
            wait(ss_freeze_a);
            wait(!ss_freeze_a);
            repeat (10) tick;

            // 2. Corrupt live WRAM during execution to verify that LOAD truly restores
            for (i = 0; i < size; i = i + 1) begin
                wram_sim_a[i] = 8'hAA;
                wram_sim_b[i] = 8'h55;
            end
            repeat (20) tick;

            // 3. LOAD
            ss_load = 1; tick; ss_load = 0;
            wait(ss_freeze_a);
            wait(!ss_freeze_a);
            repeat (20) tick;
            release a.op_cooldown; release b.op_cooldown;

            // 4. Byte-by-byte verification
            op = op + 1;
            $display("Checking restored WRAM for Test %0d...", op);
            verify_wram(size, pattern_seed);
            $display("SUCCESS: Test %0d (size=%0d, seed=0x%02h) complete.", op, size, pattern_seed);
        end
    endtask

    initial begin
        reset_n = 0; repeat (6) tick; reset_n = 1;
        vblank = 1; x = 0; z80_m1_n = 0; z80_mreq_n = 0; audio_quiescent = 1;

        $display("==================================================================");
        $display("=== INICIANDO BATERIA COMPLETA DE TESTES DIFERENCIAIS DE WRAM  ===");
        $display("==================================================================");

        // 1. SMS / GG: 8 KB WRAM (8192 bytes)
        $display("\n--- Caso 1: SMS / Game Gear (WRAM 8 KB) ---");
        systeme = 0;
        run_wram_test(8192, 8'h37);
        run_wram_test(8192, 8'hA5);

        // 2. System E: 16 KB WRAM (16384 bytes)
        $display("\n--- Caso 2: System E Arcade (WRAM 16 KB) ---");
        systeme = 1;
        run_wram_test(16384, 8'hC3);
        run_wram_test(16384, 8'h5A);
        systeme = 0;

        // 3. Ciclo consecutivo rápido: SAVE -> LOAD -> SAVE -> LOAD
        $display("\n--- Caso 3: Operações Consecutivas SAVE -> LOAD -> SAVE -> LOAD ---");
        run_wram_test(8192, 8'h11);
        run_wram_test(8192, 8'h22);

        // 4. Aborto / Watchdog test
        $display("\n--- Caso 4: Aborto forçado e reinicialização correta ---");
        init_wram(8192, 8'hEE);
        force a.op_cooldown = 0; force b.op_cooldown = 0;
        ss_save = 1; tick; ss_save = 0;
        wait(ss_freeze_a);
        // Disparar watchdog forçado
        force a.ddram_watchdog = 25'h1FFFFFE;
        force b.ddram_watchdog = 25'h1FFFFFE;
        repeat (5) tick;
        release a.ddram_watchdog; release b.ddram_watchdog;
        wait(!ss_freeze_a);
        repeat (20) tick;
        $display("Recovery from abort verified. Re-executing normal save/load...");
        run_wram_test(8192, 8'h77);

        repeat (50) tick;
        $display("\n==================================================================");
        $display("RESULTADO FINAL: Mismatches = %0d", mismatches);
        $display("==================================================================");
        if (mismatches == 0) begin
            $display("VERIFICACAO CONCLUIDA COM SUCESSO: 100%% DE EQUIVALENCIA CICLO A CICLO!");
            $finish(0);
        end else begin
            $display("FALHA: Divergencias detectadas!");
            $finish(1);
        end
    end
endmodule

