`timescale 1ns/1ps
module mapper_verification_tb;
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
    wire [63:0] mapper_in_a, mapper_in_b;
    wire mapper_set_a, mapper_set_b;
    wire [31:0] io_in_a, io_in_b;
    wire io_set_a, io_set_b;
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
        .psg_ext_in(), .psg2_ext_in(),
        .psg_div_out(psg_div_out), .psg_div_in(),
        .audio_control_out(audio_control_out), .audio_control_in(),
        .audio_quiescent(audio_quiescent), .audio_phase_out(audio_phase_out),
        .audio_phase_in(), .audio_ext_set(), .audio_phase_set(),
        .mapper_out(mapper_out), .mapper_in(mapper_in_a), .mapper_set(mapper_set_a),
        .evolution_out(evolution_out), .evolution_in(), .evolution_set(),
        .eeprom_out(eeprom_out), .eeprom_in(), .eeprom_set(),
        .wram_A(), .wram_D(wram_D), .wram_WE(), .wram_WA(), .wram_WD(),
        .nvram_A(), .nvram_D(nvram_D), .nvram_WE(), .nvram_WA(), .nvram_WD(),
        .systeme(systeme),
        .vdp2_regs(vdp2_regs), .vdp2_regs_in(), .vdp2_regs_set(),
        .cram2_out(cram2_out), .cram2_A(), .cram2_D(), .cram2_wr(),
        .vram2_en(), .vram2_A(), .vram2_D(vram2_D), .vram2_WE(), .vram2_WA(), .vram2_WD(),
        .psg2_out(psg2_out), .psg2_in(), .psg2_set(),
        .io_out(io_out), .io_in(io_in_a), .io_set(io_set_a),
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
        .mapper_out(mapper_out), .mapper_in(mapper_in_b), .mapper_set(mapper_set_b),
        .evolution_out(evolution_out), .evolution_in(), .evolution_set(),
        .eeprom_out(eeprom_out), .eeprom_in(), .eeprom_set(),
        .wram_A(), .wram_D(wram_D), .wram_WE(), .wram_WA(), .wram_WD(),
        .nvram_A(), .nvram_D(nvram_D), .nvram_WE(), .nvram_WA(), .nvram_WD(),
        .systeme(systeme),
        .vdp2_regs(vdp2_regs), .vdp2_regs_in(), .vdp2_regs_set(),
        .cram2_out(cram2_out), .cram2_A(), .cram2_D(), .cram2_wr(),
        .vram2_en(), .vram2_A(), .vram2_D(vram2_D), .vram2_WE(), .vram2_WA(), .vram2_WD(),
        .psg2_out(psg2_out), .psg2_in(), .psg2_set(),
        .io_out(io_out), .io_in(io_in_b), .io_set(io_set_b),
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

    always @(negedge clk) begin
        cycles <= cycles + 1;
        cpu_ce <= (cycles % 15 == 0);
        vdp_ce <= (cycles % 10 == 0);
        pix_ce <= (cycles % 10 == 0);
        sp_ce  <= (cycles % 5 == 0);

        #1;
        // Verify output equivalence at every single clock cycle:
        if (ss_freeze_a !== ss_freeze_b) $fatal(1, "ss_freeze mismatch");
        if (mapper_set_a !== mapper_set_b) $fatal(1, "mapper_set mismatch");
        if (mapper_set_a && (mapper_in_a !== mapper_in_b)) $fatal(1, "mapper_in mismatch at strobe! a=%h, b=%h", mapper_in_a, mapper_in_b);
        if (io_set_a !== io_set_b) $fatal(1, "io_set mismatch");
        if (io_set_a && (io_in_a !== io_in_b)) $fatal(1, "io_in mismatch at strobe!");
        if (DDRAM_WE_a !== DDRAM_WE_b) $fatal(1, "DDRAM_WE mismatch");
        if (DDRAM_RD_a !== DDRAM_RD_b) $fatal(1, "DDRAM_RD mismatch");
        if (DDRAM_WE_a && (DDRAM_ADDR_a !== DDRAM_ADDR_b || DDRAM_DIN_a !== DDRAM_DIN_b)) $fatal(1, "DDRAM write mismatch");
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
    task run_save_load(input [63:0] map_val);
        begin
            mapper_out = map_val;
            io_out = 32'h12345678 + op;
            force a.op_cooldown = 0; force b.op_cooldown = 0;
            // Trigger Save
            ss_save = 1; tick; ss_save = 0;
            wait(ss_freeze_a);
            wait(!ss_freeze_a);
            repeat (10) tick;

            // Mutate live mapper during execution to prove isolation
            mapper_out = ~map_val;
            repeat (30) tick;

            // Trigger Load
            ss_load = 1; tick; ss_load = 0;
            wait(ss_freeze_a);
            wait(!ss_freeze_a);
            repeat (20) tick;
            release a.op_cooldown; release b.op_cooldown;
            op = op + 1;
            $display("SUCCESS: Test %0d (Save/Load with mapper=0x%016h) completed with exact bit equivalence.", op, map_val);
        end
    endtask

    initial begin
        reset_n = 0; repeat (6) tick; reset_n = 1;
        vblank = 1; x = 0; z80_m1_n = 0; z80_mreq_n = 0; audio_quiescent = 1;

        $display("=== INITIATING MAPPER ALIAS VERIFICATION TESTBENCH ===");
        run_save_load(64'h0000000000000000);
        run_save_load(64'hFFFFFFFFFFFFFFFF);
        run_save_load(64'h123456789ABCDEF0);
        run_save_load(64'hA5A55A5AA5A55A5A);
        run_save_load(64'h5A5AA5A55A5AA5A5);
        run_save_load(64'h0001000200040008); // standard mapper banking bits
        run_save_load(64'hF0E1D2C3B4A59687); // NVRAM + special mapper enable bits

        $display("=== ALL MAPPER VERIFICATION TESTS COMPLETED SUCCESSFULLY WITH ZERO MISMATCHES ===");
        $finish;
    end
endmodule
