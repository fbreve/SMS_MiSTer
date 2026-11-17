# Experimento Rejeitado: evolution-restore-output-alias

## 1. Resumo da Proposta
- **Objetivo:** Eliminar o registrador intermediário de 96 bits `evolution_in` em `rtl/savestates.sv` e conectá-lo diretamente a `evolution_snap` via atribuição contínua (`assign evolution_in = evolution_snap;`).
- **Base:** Branch `experiment/io-restore-output-alias` (commit `bf0a5b5f504d4791492cd5bebcb023de15ae2d15`).
- **Data:** 01/11/2026.
- **Resultado:** **NO-GO** (Regressão de Placed ALMs em todas as 3 seeds físicas).

---

## 2. Validação Funcional (ModelSim-ASE 10.5b)
- **Simulação Diferencial:** Comparação ciclo a ciclo de `savestates_baseline` vs `savestates_candidate` em 7 cenários direcionados de SAVE e LOAD (sem Evolution, com assinatura `0xE132` ativa, payloads variados, assinaturas inativas com dados).
- **Resultado Funcional:** PASS (100% de equivalência exata bit a bit no strobe `evolution_set = '1'`, com 0 discrepâncias observáveis).

---

## 3. Medições Físicas Pareadas no Quartus 17.0.2 (Cyclone V 5CSEBA6U23I7)

| Métrica | Base S1 | Cand S1 | $\Delta$ S1 | Base S2 | Cand S2 | $\Delta$ S2 | Base S3 | Cand S3 | $\Delta$ S3 | Média $\Delta$ |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Placed ALMs** | 26.376 | 26.438 | **+62** | 26.309 | 26.373 | **+64** | 26.374 | 26.390 | **+16** | **+47.3** |
| **Needed ALMs** | 26.376 | 26.438 | **+62** | 26.309 | 26.373 | **+64** | 26.374 | 26.390 | **+16** | **+47.3** |
| **Total Regs (FFs)**| 35.347 | 35.296 | **-51** | 35.367 | 35.320 | **-47** | 35.493 | 35.272 | **-221** | **-106.3** |
| **Logic ALUTs** | 36.921 | 36.887 | **-34** | 36.920 | 36.868 | **-52** | 36.921 | 36.886 | **-35** | **-40.3** |
| **Routing ALUTs**| 12.860 | 13.013 | +153 | 12.987 | 13.147 | +160 | 12.964 | 12.999 | +35 | **+116.0** |
| **M10K Blocks** | 488 | 488 | 0 | 488 | 488 | 0 | 488 | 488 | 0 | 0.0 |
| **Worst Setup Slack**| +0.391 ns | +0.364 ns | -0.027 ns| +0.374 ns | +0.344 ns | -0.030 ns| +0.521 ns | +0.372 ns | -0.149 ns| -0.069 ns |
| **Worst Hold Slack** | +0.162 ns | +0.243 ns | +0.081 ns| +0.242 ns | +0.191 ns | -0.051 ns| +0.245 ns | +0.243 ns | -0.002 ns| +0.009 ns |
| **TNS** | **0.000** | **0.000** | 0.000 | **0.000** | **0.000** | 0.000 | **0.000** | **0.000** | 0.000 | 0.000 |

---

## 4. Diagnóstico Físico
1. **Redução Real de FFs e ALUTs Lógicas:** A eliminação do registrador removeu de fato ~51 a 221 FFs e ~40 Logic ALUTs na síntese.
2. **Causa da Regressão em Placed ALMs:** Ao retirar o estágio registrado `evolution_in`, o sinal `evolution_snap` passou a alimentar combinacionalmente tanto os circuitos de detecção/decodificação em `mapper_detect.vhd` e `system.vhd` quanto a lógica de montagem do descritor de DDR3. Isso aumentou a pressão de roteamento (observada no aumento consistente de **+116 Routing ALUTs**), forçando o Fitter a descompactar ALMs vizinhas para conseguir rotear as conexões sem estourar timing.
3. **Conclusão:** O aumento de Routing ALUTs superou o benefício da remoção dos FFs, resultando em um acréscimo médio de **+47 Placed ALMs**. O experimento deve ser rejeitado.

