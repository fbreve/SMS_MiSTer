`timescale 1ns/1ps

module tb_ym2413_reset_init;

    reg clk = 0;
    reg reset_n = 0;
    always #9.3 clk = ~clk;

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

    reg [7:0] fm_state_addr = 0;
    reg fm_state_read = 0;
    reg fm_state_write = 0;
    reg [31:0] fm_state_wdata = 0;
    wire [31:0] fm_state_rdata;
    wire fm_initialized;
    reg ss_hold = 0;
    reg legacy_reset = 0;

    reg [7:0] opll_d = 0;
    reg opll_a = 0;
    reg opll_cs_n = 0;
    reg opll_we_n = 1;
    wire [13:0] opll_mixout;

    opll dut_opll (
        .xin(clk),
        .xout(),
        .xena(cpu_ce),
        .d(opll_d),
        .a(opll_a),
        .cs_n(opll_cs_n),
        .we_n(opll_we_n),
        .ic_n(reset_n && !legacy_reset),
        .mixout(opll_mixout),
        .ss_hold(ss_hold),
        .ss_addr(fm_state_addr),
        .ss_read(fm_state_read),
        .ss_write(fm_state_write),
        .ss_wdata(fm_state_wdata),
        .ss_rdata(fm_state_rdata),
        .ss_initialized(fm_initialized)
    );

    task tick;
        begin
            @(posedge clk);
            #1;
        end
    endtask

    integer init_cycles = 0;

    initial begin
        $display("=== TESTE DE ACOMPANHAMENTO DOS CONTADORES DE INICIALIZACAO E FM_INITIALIZED ===");
        reset_n = 0;
        ss_hold = 0;
        repeat(10) tick;
        reset_n = 1;

        $display("\n[POWER-ON RESET] Acompanhando ciclos de inicializacao com ss_hold=0...");
        init_cycles = 0;
        while (!fm_initialized) begin
            init_cycles = init_cycles + 1;
            tick;
        end
        $display("[POWER-ON RESET] Concluido em %0d ciclos de clk! fm_initialized = %b", init_cycles, fm_initialized);

        // Teste de Reset com ss_hold = 1 (O que o RTL atual fazia: disparava reset legado sob freeze!)
        $display("\n[TESTE 1: RESET SOB SS_HOLD = 1 (BLOQUEIO)]");
        ss_hold = 1;
        tick;
        legacy_reset = 1;
        repeat(20) tick;
        legacy_reset = 0;
        tick;
        $display("Apos 20 ciclos de reset sob ss_hold=1: fm_initialized = %b", fm_initialized);
        repeat(150) tick;
        $display("Apos 150 ciclos sob ss_hold=1: fm_initialized = %b", fm_initialized);
        if (fm_initialized == 0) begin
            $display("-> COMPROVADO: Enquanto ss_hold=1, as memorias internas (init_slot, init_id, init_state) NAO avancam!");
        end

        // Liberar ss_hold e contar quantos ciclos sao necessarios para fm_initialized subir para 1
        $display("\n[TESTE 2: LIBERACAO DE SS_HOLD E CONTAGEM EXATA]");
        ss_hold = 0;
        init_cycles = 0;
        while (!fm_initialized) begin
            init_cycles = init_cycles + 1;
            tick;
        end
        $display("-> SUCESSO: fm_initialized subiu para 1 apos %0d ciclos de clock sem hold!", init_cycles);

        $display("=== FIM DO TESTE DE RESET E INICIALIZACAO ===");
        $finish;
    end

endmodule

