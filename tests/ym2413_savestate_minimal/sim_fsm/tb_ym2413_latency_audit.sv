`timescale 1ns/1ps

module tb_ym2413_latency_audit;

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
        .ic_n(reset_n),
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

    initial begin
        $display("=== AUDITORIA DE LATENCIA EFETIVA DE LEITURA (RAM SINCRONA OPLL) ===");
        reset_n = 0;
        ss_hold = 0;
        repeat(10) tick;
        reset_n = 1;
        while (!fm_initialized) tick;
        $display("[INIT] OPLL inicializado com sucesso! (fm_initialized=1)");

        // Entrar em freeze / hold para operar savestate
        ss_hold = 1;
        tick;

        // Pre-carregar canais e envelopes com valores conhecidos via escrita de savestate
        // Canal 0 (Addr 0) = 0x000055AA
        fm_state_addr <= 8'd0;
        fm_state_wdata <= 32'h000055AA;
        fm_state_write <= 1;
        tick;
        // Canal 1 (Addr 1) = 0x00001234
        fm_state_addr <= 8'd1;
        fm_state_wdata <= 32'h00001234;
        tick;
        // Envelope 0 (Addr 13) = 0x01ABCDEF
        fm_state_addr <= 8'd13;
        fm_state_wdata <= 32'h01ABCDEF;
        tick;
        fm_state_write <= 0;
        tick;

        // Medir latencia ciclo a ciclo para ler Addr 0:
        $display("\n--- TESTE DE LATENCIA CICLO A CICLO (Canal 0, Addr 0) ---");
        $display("T0: Colocando addr=0, read=1 na borda de subida");
        fm_state_addr <= 8'd0;
        fm_state_read <= 1;
        tick; // Transicao para T1 (1 ciclo de relogio transcorrido)
        $display("T1 (apos 1 clock posedge): fm_state_rdata = %08h (Esperado: 000055AA)", fm_state_rdata);
        if (fm_state_rdata == 32'h000055AA) begin
            $display("-> SUCESSO: Latencia de leitura eh de exatamente 1 ciclo!");
        end else begin
            $display("-> FALHA: Dado ainda nao disponivel em T1!");
        end
        tick; // T2
        $display("T2 (apos 2 clock posedges): fm_state_rdata = %08h", fm_state_rdata);

        // Medir latencia ciclo a ciclo para ler Addr 1:
        $display("\n--- TESTE DE LATENCIA CICLO A CICLO (Canal 1, Addr 1) ---");
        $display("T0: Colocando addr=1, read=1");
        fm_state_addr <= 8'd1;
        fm_state_read <= 1;
        tick;
        $display("T1 (apos 1 clock posedge): fm_state_rdata = %08h (Esperado: 00001234)", fm_state_rdata);
        if (fm_state_rdata == 32'h00001234) begin
            $display("-> SUCESSO: Latencia de leitura eh de exatamente 1 ciclo!");
        end else begin
            $display("-> FALHA: Dado ainda nao disponivel em T1!");
        end
        tick;
        $display("T2 (apos 2 clock posedges): fm_state_rdata = %08h", fm_state_rdata);

        // Medir latencia ciclo a ciclo para ler Envelope 0 (Addr 13):
        $display("\n--- TESTE DE LATENCIA CICLO A CICLO (Envelope 0, Addr 13) ---");
        $display("T0: Colocando addr=13, read=1");
        fm_state_addr <= 8'd13;
        fm_state_read <= 1;
        tick;
        $display("T1 (apos 1 clock posedge): fm_state_rdata = %08h (Esperado: 01ABCDEF)", fm_state_rdata);
        if (fm_state_rdata == 32'h01ABCDEF) begin
            $display("-> SUCESSO: Latencia de leitura de envelope eh de exatamente 1 ciclo!");
        end else begin
            $display("-> FALHA: Dado ainda nao disponivel em T1!");
        end
        tick;
        $display("T2 (apos 2 clock posedges): fm_state_rdata = %08h", fm_state_rdata);

        $display("\n=== CONCLUSAO DA AUDITORIA DE LATENCIA ===");
        $finish;
    end

endmodule
