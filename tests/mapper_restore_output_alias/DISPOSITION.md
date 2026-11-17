# Experimento Rejeitado: mapper-restore-output-alias

## 1. Resumo da Proposta
- **Objetivo:** Eliminar o registrador intermediário de 64 bits `mapper_in` em `rtl/savestates.sv` e conectá-lo diretamente a `mapper_snap` via atribuição contínua (`assign mapper_in = mapper_snap;`).
- **Base:** Branch `experiment/io-restore-output-alias` (commit `bf0a5b5f504d4791492cd5bebcb023de15ae2d15`).
- **Data:** 01/11/2026.
- **Resultado:** **NO-GO** (Regressão de área consistente em todas as seeds testadas).

---

## 2. Validação Funcional (ModelSim-ASE 10.5b)
- **Simulação Diferencial:** Instanciação concorrente do baseline (`savestates_baseline` com `io_in` otimizado) e do candidato (`savestates_candidate` com `io_in` + `mapper_in`).
- **Ciclos e Operações:** 7 baterias completas de SAVE/LOAD cobrindo vetores extremos (`0x0000...`, `0xFFFF...`, padrões de banking Sega/Korea e flags de NVRAM/Castle).
- **Resultado Funcional:** PASS (100% de equivalência exata bit a bit no strobe `mapper_set = '1'`, com 0 discrepâncias observáveis).

---

## 3. Medições Físicas Pareadas no Quartus 17.0.2 (Cyclone V 5CSEBA6U23I7)

| Métrica | Base S1 | Cand S1 | $\Delta$ S1 | Base S2 | Cand S2 | $\Delta$ S2 | Base S3 | Cand S3 | $\Delta$ S3 |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Placed ALMs** | 26.376 | 26.424 | **+48** | 26.309 | 26.493 | **+184** | 26.374 | 26.464 | **+90** |
| **Needed ALMs** | 26.376 | 26.424 | **+48** | 26.309 | 26.493 | **+184** | 26.374 | 26.464 | **+90** |
| **Total Regs (FFs)**| 35.347 | 35.421 | +74 | 35.367 | 35.296 | -71 | 35.493 | 35.400 | -93 |
| **Logic ALUTs** | 36.921 | 36.924 | +3 | 36.920 | 36.924 | +4 | 36.921 | 36.915 | -6 |
| **Routing ALUTs**| 12.860 | 12.922 | +62 | 12.957 | 12.957 | 0 | 12.964 | 13.026 | +62 |
| **M10K Blocks** | 488 | 488 | 0 | 488 | 488 | 0 | 488 | 488 | 0 |
| **Worst Setup Slack**| +0.391 ns | +0.661 ns | +0.270 ns| +0.374 ns | +0.606 ns | +0.232 ns| +0.521 ns | +0.652 ns | +0.131 ns|
| **Worst Hold Slack** | +0.162 ns | +0.245 ns | +0.083 ns| +0.242 ns | +0.244 ns | +0.002 ns| +0.245 ns | +0.244 ns | -0.001 ns|
| **TNS** | **0.000** | **0.000** | 0.000 | **0.000** | **0.000** | 0.000 | **0.000** | **0.000** | 0.000 |

---

## 4. Diagnóstico e Causa Raiz da Regressão Física
1. **Regressão Média de Placed ALMs:** **+107 ALMs** (+48 na Seed 1, +184 na Seed 2, +90 na Seed 3).
2. **Causa Estrutural:** O registrador `mapper_in` atuava como uma barreira física de fanout e retiming entre a FSM central de savestates e as dezenas de decodificadores e multiplexadores distribuídos nos módulos `mapper_ctrl.vhd`, `mapper_detect.vhd` e `system.vhd`.
3. **Comportamento do Fitter:** Ao conectar `mapper_snap` diretamente aos consumidores, o fanout elevado e compartilhado obrigou o compilador a duplicar lógica e desempacotar ALMs que antes compartilhavam recursos, degradando a densidade de empacotamento do Cyclone V.
4. **Conclusão:** A eliminação de registradores RTL em barramentos com fanout distribuído complexo não garante economia de ALMs e, neste caso específico, prejudica sistematicamente a área. Experimento definitivamente rejeitado.

