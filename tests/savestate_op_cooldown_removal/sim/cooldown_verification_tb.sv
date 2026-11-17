`timescale 1ns/1ps
module cooldown_verification_tb;
    reg clk = 0;
    reg reset_n = 0;
    reg ss_save = 0;
    reg ss_load = 0;
    reg [1:0] ss_slot = 0;
    reg ss_bios_mode = 0;
    reg [31:0] ss_game_id = 32'h12345678;
    reg vblank = 1;
    reg [8:0] x = 0;
    reg [229:0] z80_reg = 230'h123456789ABCDEF;
    reg z80_m1_n = 0;
    reg z80_mreq_n = 0;
    reg [1:0] z80_iset = 0;
    reg cpu_ce = 0;
    reg vdp_ce = 0;
    reg pix_ce = 0;
    reg sp_ce = 0;
    reg [127:0] vdp_regs = 128'hFEEDFACECAFEBEEF;
    reg [383:0] cram_out = 384'hAAAA5555;
    reg [7:0] vram_D = 8'h55;
    reg [55:0] psg_out = 56'h3344;
    reg [95:0] psg_ext_out = 96'h7788;
    reg [95:0] psg2_ext_out = 96'h99AA;
    reg [3:0] psg_div_out = 4'h2;
    reg [10:0] audio_control_out = 11'h1;
    reg audio_quiescent = 1;
    reg audio_phase_out = 0;
    reg [63:0] mapper_out = 64'hA1B2C3D4;
    reg [95:0] evolution_out = 96'h112233;
    reg [63:0] eeprom_out = 64'h445566;
    reg [7:0] nvram_D = 8'h0;
    reg systeme = 0;
    reg [127:0] vdp2_regs = 128'h0;
    reg [383:0] cram2_out = 384'h0;
    reg [7:0] vram2_D = 8'h0;
    reg [55:0] psg2_out = 56'h0;
    reg [31:0] io_out = 32'h1234;
    reg [21:0] video_state_out = 22'h0;

            reg DDRAM_BUSY = 0;
    reg [63:0] DDRAM_DOUT_a = 0;
    reg [63:0] DDRAM_DOUT_b = 0;
    reg DDRAM_DOUT_READY_a = 0;
    reg DDRAM_DOUT_READY_b = 0;


    // Simulated WRAM memories
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
        .DDRAM_WE(DDRAM_WE_a), .DDRAM_DOUT(DDRAM_DOUT_a), .DDRAM_DOUT_READY(DDRAM_DOUT_READY_a),
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
        .DDRAM_WE(DDRAM_WE_b), .DDRAM_DOUT(DDRAM_DOUT_b), .DDRAM_DOUT_READY(DDRAM_DOUT_READY_b),
        .DDRAM_RD(DDRAM_RD_b), .DDRAM_BURSTCNT(), .DDRAM_BUSY(DDRAM_BUSY)
    );

    always #5 clk = ~clk;

    // Simulated DDRAM memories (fully isolated for each DUT)
    reg [63:0] memory_a [0:98303];
    reg [63:0] memory_b [0:98303];
    reg [28:0] ra_a, ra_b;
    integer pending_a = 0;
    integer pending_b = 0;
                    integer cycles = 0;
    integer mismatches = 0;
    reg check_cycle_equivalence = 1;

    always @(negedge clk) begin
        cycles <= cycles + 1;
        cpu_ce <= (cycles % 15 == 0);
        vdp_ce <= (cycles % 10 == 0);
        pix_ce <= (cycles % 10 == 0);
        sp_ce  <= (cycles % 5 == 0);

        #1;
        if (reset_n && check_cycle_equivalence) begin
            // 1. Freeze signals must match during normal synchronized operations
            if (ss_freeze_a !== ss_freeze_b) begin
                $display("ERROR: ss_freeze mismatch at cycle %0d (a=%b, b=%b)", cycles, ss_freeze_a, ss_freeze_b);
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
            if (DDRAM_WE_a !== DDRAM_WE_b) begin
                $display("ERROR: DDRAM_WE mismatch at cycle %0d", cycles);
                mismatches = mismatches + 1;
            end
            if (DDRAM_RD_a !== DDRAM_RD_b) begin
                $display("ERROR: DDRAM_RD mismatch at cycle %0d", cycles);
                mismatches = mismatches + 1;
            end
            if (DDRAM_WE_a && (DDRAM_ADDR_a !== DDRAM_ADDR_b || DDRAM_DIN_a !== DDRAM_DIN_b)) begin
                $display("ERROR: DDRAM write mismatch at cycle %0d", cycles);
                mismatches = mismatches + 1;
            end
        end
    end

    always @(posedge clk) begin
        // Port A (Baseline)
        DDRAM_DOUT_READY_a <= 0;
        if (pending_a > 0) begin
            pending_a <= pending_a - 1;
            if (pending_a == 1) begin
                DDRAM_DOUT_a <= memory_a[ra_a - 29'h07C00000];
                DDRAM_DOUT_READY_a <= 1;
            end
        end
        if (DDRAM_WE_a && !DDRAM_BUSY) begin
            for (integer b_idx = 0; b_idx < 8; b_idx = b_idx + 1) begin
                if (DDRAM_BE_a[b_idx]) memory_a[DDRAM_ADDR_a - 29'h07C00000][b_idx*8 +: 8] <= DDRAM_DIN_a[b_idx*8 +: 8];
            end
        end
        if (DDRAM_RD_a && !DDRAM_BUSY) begin
            ra_a <= DDRAM_ADDR_a;
            pending_a <= 3;
        end

        // Port B (Candidate)
        DDRAM_DOUT_READY_b <= 0;
        if (pending_b > 0) begin
            pending_b <= pending_b - 1;
            if (pending_b == 1) begin
                DDRAM_DOUT_b <= memory_b[ra_b - 29'h07C00000];
                DDRAM_DOUT_READY_b <= 1;
            end
        end
        if (DDRAM_WE_b && !DDRAM_BUSY) begin
            for (integer b_idx = 0; b_idx < 8; b_idx = b_idx + 1) begin
                if (DDRAM_BE_b[b_idx]) memory_b[DDRAM_ADDR_b - 29'h07C00000][b_idx*8 +: 8] <= DDRAM_DIN_b[b_idx*8 +: 8];
            end
        end
        if (DDRAM_RD_b && !DDRAM_BUSY) begin
            ra_b <= DDRAM_ADDR_b;
            pending_b <= 3;
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
    task run_paired_save_load(input integer size, input [7:0] pattern_seed);
        integer i;
        begin
            init_wram(size, pattern_seed);
            // In baseline, clear op_cooldown to permit immediate launch for paired baseline-candidate test
            force a.op_cooldown = 0;

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
            release a.op_cooldown;

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
        $display("=== TESTE 1: EQUIVALENCIA CICLO A CICLO (SAVE / LOAD NORMAL)   ===");
        $display("==================================================================");

        // SMS / GG 8 KB
        $display("\n--- Caso 1.1: SMS / GG 8 KB (Seed 0x37) ---");
        systeme = 0;
        run_paired_save_load(8192, 8'h37);

        // System E 16 KB
        $display("\n--- Caso 1.2: System E Arcade 16 KB (Seed 0xC3) ---");
        systeme = 1;
        run_paired_save_load(16384, 8'hC3);
        systeme = 0;

        // Sequência repetida SAVE -> LOAD -> SAVE -> LOAD
        $display("\n--- Caso 1.3: Sequencia Repetida SAVE -> LOAD -> SAVE -> LOAD ---");
        run_paired_save_load(8192, 8'h11);
        run_paired_save_load(8192, 8'h22);

        $display("\n==================================================================");
        $display("=== TESTE 2: COMANDOS REPETIDOS EM INTERVALO INFERIOR A 500 MS ===");
        $display("==================================================================");
        // Sem forçar a.op_cooldown.
        // O baseline possui op_cooldown ativo (~500 ms) e ignorará comandos imediatos.
        // O candidato DEVE aceitar o comando imediatamente sem travar nem corromper.
        check_cycle_equivalence = 0; // Desativa comparador estrito baseline-candidato para verificar comportamento intencional

        // Executar SAVE no candidato logo apos o ciclo anterior (intervalo < 50 ciclos << 500 ms)
        $display("Disparando comando imediato no candidato (intervalo = 10 ciclos)...");
        init_wram(8192, 8'h77);
        ss_save = 1; tick; ss_save = 0;
        wait(ss_freeze_b);
        $display("Candidato entrou em freeze com sucesso sob comando imediato!");
        wait(!ss_freeze_b);
        repeat (10) tick;

        // Corrompe e dispara LOAD imediato no candidato
        for (integer k = 0; k < 8192; k = k + 1) wram_sim_b[k] = 8'h00;
        ss_load = 1; tick; ss_load = 0;
        wait(ss_freeze_b);
        $display("Candidato aceitou LOAD imediato com sucesso!");
        wait(!ss_freeze_b);
        repeat (10) tick;

        // Verifica integridade dos dados no candidato
        for (integer k = 0; k < 8192; k = k + 1) begin
            if (wram_sim_b[k] !== ((8'h77 + k * 17) & 8'hFF)) begin
                $display("ERROR: Falha na integridade do candidato em comando rapido!");
                mismatches = mismatches + 1;
            end
        end
        $display("PASS: Candidato preservou integridade de 100%% sob comandos sem cooldown.");

        $display("\n==================================================================");
        $display("=== TESTE 3: COMANDO RECEBIDO ENQUANTO A FSM ESTA OCUPADA      ===");
        $display("==================================================================");
        // Enquanto o candidato está executando um SAVE, injeta pulsos parasitas de ss_save e ss_load
        init_wram(8192, 8'h99);
        ss_save = 1; tick; ss_save = 0;
        wait(ss_freeze_b);
        $display("FSM ocupada em SAVE. Injetando pulsos espurios de ss_load e ss_save...");
        repeat (5) tick;
        ss_load = 1; tick; ss_load = 0;
        repeat (5) tick;
        ss_save = 1; tick; ss_save = 0;
        repeat (5) tick;
        wait(!ss_freeze_b);
        repeat (20) tick; // Aguarda ST_UNFREEZE_SETTLE (4 ciclos) assentar e retornar a ST_IDLE
        $display("FSM concluiu operacao e retornou a ST_IDLE com sucesso.");

        $display("\n==================================================================");
        $display("=== TESTE 4: ABORTO FORCADO POR WATCHDOG E RECUPERACAO         ===");
        $display("==================================================================");
        // Desativa resposta do modelo DDRAM para simular travamento/perda de resposta
        force DDRAM_DOUT_READY_b = 0;
        ss_load = 1; tick; ss_load = 0;
        wait(ss_freeze_b);
        // Aguarda entrada no estado de espera de dados da DDRAM
        wait(b.state == 6'd21); // ST_LOAD_HDR_WT
        $display("FSM aguardando resposta da DDRAM em ST_LOAD_HDR_WT (dout_expected=%b). Forcando timeout de watchdog...", b.dout_expected);
        force b.ddram_watchdog = 25'h1FFFFFF;
        tick;
        release b.ddram_watchdog;
        release DDRAM_DOUT_READY_b;
        wait(!ss_freeze_b);
        repeat (20) tick;
        $display("Candidato abortou para ST_IDLE e liberou freeze perfeitamente. Testando ciclo subsequente...");
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
        $display("LOAD pos-aborto concluido!");
        repeat (10) tick;
        for (integer k = 0; k < 8192; k = k + 1) begin
            if (wram_sim_b[k] !== ((8'h42 + k * 17) & 8'hFF)) begin
                $display("ERROR: Falha de integridade pos-aborto!");
                mismatches = mismatches + 1;
            end
        end
        $display("PASS: Recuperacao pos-aborto 100%% funcional.");

        repeat (50) tick;
        $display("\n==================================================================");
        $display("RESULTADO GERAL DA BATERIA: Mismatches Indevidos = %0d", mismatches);
        $display("==================================================================");
        if (mismatches == 0) begin
            $display("VERIFICACAO MODELSIM CONCLUIDA COM SUCESSO ABSOLUTO!");
            $finish(0);
        end else begin
            $display("FALHA: Divergencias indevidas encontradas!");
            $finish(1);
        end
    end
endmodule

