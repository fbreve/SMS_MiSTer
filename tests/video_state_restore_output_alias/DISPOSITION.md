# Relatório de Disposição: Experimento `video-state-restore-output-alias`

**Data:** 02 de Novembro de 2026  
**Dispositivo:** Altera/Intel Cyclone V `5CSEBA6U23I7` (Quartus Prime Lite 17.0.2)  
**Baseline:** `experiment/io-restore-output-alias` (`bf0a5b5f`)  
**Branch do Experimento:** `experiment/video-state-restore-output-alias` (commit `532ab2a`)  
**Veredito:** **NO-GO (Rejeitado por Regressão Física na Seed 2)**

---

## 1. Descrição da Modificação Experimental
Eliminação do registrador físico de saída `video_state_in` de 22 bits em `rtl/savestates.sv`, substituindo-o por atribuição contínua direta a partir do snapshot `video_snap`:
```systemverilog
- output reg [21:0] video_state_in,
+ output     [21:0] video_state_in,
...
+ assign video_state_in = video_snap;
```
Remoção das atribuições em `ST_RESET` (`video_state_in <= 22'd0;`) e `ST_RESTORE_VIDEO` (`video_state_in <= video_snap;`).

---

## 2. Resultados da Simulação Funcional Diferencial
- **Testbench:** `tests/video_state_restore_output_alias/sim/video_state_verification_tb.sv`
- **Duração:** 135,5 ms de tempo de simulação (>13,5 milhões de ciclos de clock).
- **Cobertura:** 14 operações completas de SAVE e LOAD cobrindo bordas extremas de varredura, posições ativas e blanking, System E, savestates legados e acionamento de timeout de alinhamento.
- **Resultado Funcional:** **100% de equivalência exata**, zero divergências registradas no consumidor `rtl/video.vhd` e nas saídas do módulo.

---

## 3. Avaliação Física Pareada (3 Seeds)

| Métrica | Seed 1 Base | Seed 1 Cand | S1 Delta | Seed 2 Base | Seed 2 Cand | S2 Delta | Seed 3 Base | Seed 3 Cand | S3 Delta | Média Delta |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Placed ALMs** | 26.376 | 26.300 | **-76** | 26.309 | 26.346 | **+37** | 26.374 | 26.310 | **-64** | **-34,3** |
| **Needed ALMs** | 26.376 | 26.300 | **-76** | 26.309 | 26.346 | **+37** | 26.374 | 26.310 | **-64** | **-34,3** |
| **Registers** | 35.347 | 35.445 | **+98** | 35.367 | 35.456 | **+89** | 35.493 | 35.499 | **+6** | **+64,3** |
| **Logic ALUTs** | 36.921 | 36.762 | **-159** | 36.920 | 36.772 | **-148** | 36.921 | 36.762 | **-159** | **-155,3** |
| **Routing ALUTs** | 12.860 | 13.056 | **+196** | 12.987 | 13.094 | **+107** | 12.964 | 13.188 | **+224** | **+175,7** |
| **M10K Blocks** | 488 | 488 | 0 | 488 | 488 | 0 | 488 | 488 | 0 | 0,0 |
| **Setup Slack (ns)** | 0,391 | 0,473 | +0,082 | 0,374 | 0,377 | +0,003 | 0,521 | 0,358 | -0,163 | -0,026 |
| **Hold Slack (ns)** | 0,162 | 0,244 | +0,082 | 0,242 | 0,245 | +0,003 | 0,245 | 0.243 | -0,002 | +0,028 |
| **TNS (ns)** | 0,000 | 0,000 | 0,000 | 0,000 | 0,000 | 0,000 | 0,000 | 0,000 | 0,000 | 0,000 |

---

## 4. Diagnóstico Técnico da Rejeição
1. **Regressão na Seed 2:** Enquanto as seeds 1 e 3 apresentaram redução (-76 e -64 Placed ALMs), a **Seed 2 regrediu +37 Placed ALMs**. Pelo critério estabelecido no projeto, a redução deve ser consistente através das três seeds.
2. **Explosão de Routing ALUTs e Duplicação de Registradores:** O Fitter utilizou em média **+175,7 Routing ALUTs** e aumentou os registradores totais em **+64,3 FFs**. Ao retirar o registrador de saída `video_state_in`, o sinal `video_snap` passa a alimentar simultaneamente a lógica de timeout (`video_state_out[21:4] == video_snap[21:4]`) e os pinos de entrada da entidade `video.vhd`. Essa carga combinacional direta forçou o roteador do Quartus a duplicar flip-flops internos e inserir células de route-through para fechar o timing do clock de 54 MHz.
3. **Conclusão:** O isolamento temporal provido pelo registrador dedicado de saída é benéfico para o particionamento físico do Cyclone V.

---

## 5. Ações Tomadas
1. Resultados arquivados em `tests/video_state_restore_output_alias/`.
2. O working tree foi limpo e retornado para a branch base `experiment/io-restore-output-alias` no commit `bf0a5b5f`.

