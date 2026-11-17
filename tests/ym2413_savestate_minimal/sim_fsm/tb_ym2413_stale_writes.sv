`timescale 1ns/1ps

module tb_ym2413_stale_writes;

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
        $display("=== TESTE DE STALE WRITES APOS LOAD (REGS_WR, USER_VOICE_WR, MEMWR) ===");
        reset_n = 0;
        ss_hold = 0;
        repeat(10) tick;
        reset_n = 1;
        while (!fm_initialized) tick;
        $display("[INIT] OPLL inicializado.");

        // Fase 1: Simular operacao normal da CPU escrevendo nos registradores do OPLL
        // Escreve no Canal 0: Addr 0x20 = 0x15 (Key=1, Block=2, FNum=5)
        opll_a <= 0;
        opll_d <= 8'h20;
        opll_we_n <= 0;
        tick;
        opll_we_n <= 1;
        repeat(5) tick;
        opll_a <= 1;
        opll_d <= 8'h15;
        opll_we_n <= 0;
        tick;
        opll_we_n <= 1;
        repeat(80) tick; // Aguarda processamento dos slots

        // Fase 2: Ocorre Freeze / Savestate HOLD
        $display("[FREEZE] Entrando em ss_hold=1...");
        ss_hold = 1;
        tick;

        // Fase 3: Simulacao de LOAD restaurando Canal 0 com novo valor: 0x00003311 (Key=0, etc.)
        $display("[LOAD] Restaurando Canal 0 via savestate com 0x00003311...");
        fm_state_addr <= 8'd0;
        fm_state_wdata <= 32'h00003311;
        fm_state_write <= 1;
        tick;
        fm_state_write <= 0;
        tick;

        // Verificar se Canal 0 foi restaurado corretamente no RegisterMemory
        fm_state_addr <= 8'd0;
        fm_state_read <= 1;
        tick; // wait state
        tick;
        $display("[VERIFICACAO EM HOLD] Canal 0 = %08h (Esperado: 00003311)", fm_state_rdata);
        if (fm_state_rdata != 32'h00003311) begin
            $display("[ERRO] Falha ao escrever Canal 0 em hold!");
        end
        fm_state_read <= 0;
        tick;

        // Fase 4: UNFREEZE (ss_hold volta a 0)
        // Observar se o valor restaurado eh corrompido por pipelines antigos da CPU
        $display("[UNFREEZE] Liberando ss_hold para 0...");
        ss_hold = 0;
        repeat(150) tick; // Varios ciclos com clock enable ativo

        // Verificar novamente Canal 0 (entrando em hold momentaneo para ler)
        ss_hold = 1;
        tick;
        fm_state_addr <= 8'd0;
        fm_state_read <= 1;
        tick;
        tick;
        $display("[APOS UNFREEZE] Canal 0 = %08h (Esperado: 00003311)", fm_state_rdata);
        if (fm_state_rdata == 32'h00003311) begin
            $display("-> SUCESSO: Nenhuma escrita obsoleta (stale write) sobrescreveu o estado restaurado!");
        end else begin
            $display("-> FALHA: Stale write corrompeu o registrador restaurado!");
        end

        $display("=== FIM DO TESTE DE STALE WRITES ===");
        $finish;
    end

endmodule

