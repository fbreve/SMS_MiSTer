# Relatório de Disposição: Experimento `psg_ext_in` (Alias de Saída)

## 1. Identificação do Experimento
- **Objetivo:** Avaliar a substituição do registrador de 96 bits `psg_ext_in` por um alias direto do registrador de snapshot `psg_ext_snap` em `rtl/savestates.sv`.
- **Branch:** `experiment/psg-ext-restore-output-alias`
- **Baseline:** `experiment/io-restore-output-alias` (`bf0a5b5f`)
- **Dispositivo:** Cyclone V `5CSEBA6U23I7`
- **Ferramenta:** Quartus Prime Lite 17.0.2

---

## 2. Resultados Físicos nas Três Seeds Pareadas

| Métrica | Seed 1 (Base) | Seed 1 (Cand) | Δ S1 | Seed 2 (Base) | Seed 2 (Cand) | Δ S2 | Seed 3 (Base) | Seed 3 (Cand) | Δ S3 | Média Δ |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Placed ALMs** | 26.376 | 26.318 | **-58** | 26.309 | 26.374 | **+65** | 26.374 | 26.324 | **-50** | **-14,3** |
| **Needed ALMs** | 26.376 | 26.318 | **-58** | 26.309 | 26.374 | **+65** | 26.374 | 26.324 | **-50** | **-14,3** |
| **Total Registers** | 35.347 | 35.292 | **-55** | 35.367 | 35.422 | **+55** | 35.493 | 35.389 | **-104** | **-34,7** |
| **Logic ALUTs** | 36.921 | 36.891 | **-30** | 36.920 | 36.895 | **-25** | 36.921 | 36.898 | **-23** | **-26,0** |
| **Routing ALUTs**| 12.860 | 12.966 | **+106** | 12.987 | 13.017 | **+30** | 12.964 | 12.880 | **-84** | **+17,3** |
| **M10K Blocks** | 488 | 488 | 0 | 488 | 488 | 0 | 488 | 488 | 0 | **0** |
| **Worst Setup Slack** | +0,391 ns | +0,692 ns | +0,301 ns | +0,374 ns | +0,457 ns | +0,083 ns | +0,521 ns | +0,482 ns | -0,039 ns | **+0,115 ns** |
| **Worst Hold Slack** | +0,162 ns | +0,199 ns | +0,037 ns | +0,242 ns | +0,240 ns | -0,002 ns | +0,245 ns | +0,232 ns | -0,013 ns | **+0,007 ns** |
| **TNS** | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | **0** |

---

## 3. Análise dos Resultados e Veredito

1. **Inconsistência Entre Seeds:**
   - Na **Seed 1**, houve redução de **58 Placed ALMs**.
   - Na **Seed 3**, houve redução de **50 Placed ALMs**.
   - Contudo, na **Seed 2**, houve uma **regressão de +65 Placed ALMs** (e +55 Total Registers no fitter final).
2. **Critério de GO Não Satisfeito:**
   - O critério exigia redução **consistente** de Placed ALMs em todas as três seeds pareadas.
   - A média líquida foi de apenas **-14,3 Placed ALMs**, com uma regressão substancial em uma das seeds, evidenciando ruído de empacotamento físico do Fitter ao lidar com um barramento de 96 bits sem o registrador de borda local.

### **Veredito:** NO-GO
A alteração de `psg_ext_in` não produziu economia consistente e apresentou regressão em uma das seeds.

