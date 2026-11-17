# Relatório de Disposição: Experimento `wram-dma-addr-unification`

**Data:** 02 de Novembro de 2026  
**Dispositivo:** Altera/Intel Cyclone V `5CSEBA6U23I7` (Quartus Prime Lite 17.0.2)  
**Baseline:** `experiment/io-restore-output-alias` (`bf0a5b5f`)  
**Branch do Experimento:** `experiment/wram-dma-addr-unification` (commit `a5f4cf7`)  
**Veredito:** **NO-GO (Rejeitado por Regressão Física Consistente nas Três Seeds)**

---

## 1. Descrição da Modificação Experimental
Unificação dos registradores de 14 bits `wram_save_addr` e `wram_load_addr` em um único registrador `wram_dma_addr` em `rtl/savestates.sv`:
```systemverilog
- reg [13:0]  wram_save_addr;
- reg [13:0]  wram_load_addr;
+ reg [13:0]  wram_dma_addr;
```
Substituição direta de todas as referências procedurais de leitura, incremento e inicialização nos estados `ST_SAVE_VRAM_READ`, `ST_SAVE_WRAM_READ`, `ST_LOAD_VRAM_WRITE` e `ST_LOAD_WRAM_WRITE`.

---

## 2. Validação Funcional Diferencial (ModelSim)
- **Testbench:** `tests/wram_dma_addr_unification/sim/wram_verification_tb.sv`
- **Resultados:**
  - 8.192 bytes verificados byte a byte em modo SMS/GG (8 KB).
  - 16.384 bytes verificados byte a byte em modo System E Arcade (16 KB).
  - Ciclos consecutivos SAVE $\rightarrow$ LOAD $\rightarrow$ SAVE $\rightarrow$ LOAD testados com integridade perfeita.
  - Aborto por watchdog simulado com recuperação e reinicialização correta.
  - **Zero mismatches ciclo a ciclo** nos barramentos `wram_A`, `wram_WA`, `wram_WD`, `wram_WE` e DDRAM.

---

## 3. Avaliação Física Pareada (Quartus Prime Lite 17.0.2 - 3 Seeds)

| Métrica | Seed 1 Base | Seed 1 Cand | S1 Delta | Seed 2 Base | Seed 2 Cand | S2 Delta | Seed 3 Base | Seed 3 Cand | S3 Delta | Média Delta |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Placed ALMs** | 26.376 | 26.385 | **+9** | 26.309 | 26.337 | **+28** | 26.374 | 26.399 | **+25** | **+20,7** |
| **Needed ALMs** | 26.376 | 26.385 | **+9** | 26.309 | 26.337 | **+28** | 26.374 | 26.399 | **+25** | **+20,7** |
| **Registers** | 35.347 | 35.427 | **+80** | 35.367 | 35.544 | **+177** | 35.493 | 35.505 | **+12** | **+89,7** |
| **Logic ALUTs** | 36.921 | 36.890 | **-31** | 36.920 | 36.886 | **-34** | 36.921 | 36.891 | **-30** | **-31,7** |
| **Routing ALUTs** | 12.860 | 12.973 | **+113** | 12.987 | 13.031 | **+44** | 12.964 | 13.036 | **+72** | **+76,3** |
| **M10K Blocks** | 488 | 488 | 0 | 488 | 488 | 0 | 488 | 488 | 0 | 0,0 |
| **Setup Slack (ns)** | 0,391 | 0,471 | +0,080 | 0,374 | 0,410 | +0,036 | 0,521 | 0,512 | -0,009 | +0,036 |
| **Hold Slack (ns)** | 0,162 | 0,247 | +0,085 | 0,242 | 0,240 | -0,002 | 0,245 | 0,220 | -0,025 | +0,019 |
| **TNS (ns)** | 0,000 | 0,000 | 0,000 | 0,000 | 0,000 | 0,000 | 0,000 | 0,000 | 0,000 | 0,000 |

---

## 4. Diagnóstico Físico da Regressão
1. **Regressão Consistente de Placed ALMs:** Todas as três seeds apresentaram aumento físico (+9, +28 e +25 Placed ALMs), com regressão média de **+20,7 ALMs**.
2. **Causa Raiz Arquitetural no Fitter:**
   - Embora a síntese lógica tenha economizado **-31,7 Logic ALUTs** (removendo a lógica duplicada do somador de incremento), o contador unificado `wram_dma_addr` passou a ter múltiplos conjuntos de condições de controle de clock enable (acionado em `ST_SAVE_WRAM_READ` com pipelining e em `ST_LOAD_WRAM_WRITE` sob `wram_byte_cnt`).
   - Isso aumentou o fanout e a complexidade do sinal de controle dos flip-flops.
   - Mais crítico: o sinal agora alimenta simultaneamente as portas de leitura (`wram_A`) e escrita (`wram_WA`). Para atender às restrições de tempo do Cyclone V sem violar o setup do clock de 54 MHz, o roteador do Quartus precisou **duplicar registradores** (+89,7 registradores médios) e inserir **+76,3 Routing ALUTs**.
3. **Conclusão para os Pares NVRAM e VRAM:** Se a WRAM (que é o par mais simples) regrediu consistentemente por duplicação de roteamento, a unificação de NVRAM e VRAM (que possuem multiplexações ainda mais complexas) certamente apresentará comportamento similar ou pior.

---

## 5. Disposição
1. Resultados arquivados em `tests/wram_dma_addr_unification/`.
2. A branch experimental `experiment/wram-dma-addr-unification` foi removida.
3. O repositório está limpo e posicionado na branch base `experiment/io-restore-output-alias` no commit `bf0a5b5f`.

