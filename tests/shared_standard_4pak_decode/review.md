# Avaliação shared-standard-4pak-bank-decode

**NO-GO**: candidato aumentou ALMs nas duas seeds.

Baseline: `8443a0d19a88aff7a5900011bccf386daf146945`. Candidato: `613ecb4f2ef6e17b6cba511e95119bcd9186a852`, correspondente ao ref remoto local `origin/experiment/shared-standard-4pak-bank-decode`. O master local está em `ab09fdf41221c9e3e77eee87264a125ba43021fe`; nenhum checkout, commit, merge, push ou PR foi realizado. HEAD, refs, index e diff rastreado permaneceram idênticos.

## Método

Quatro árvores independentes extraídas de blobs Git, sem databases ou outputs anteriores. Quartus Prime Lite 17.0.2 Build 602; Cyclone V 5CSEBA6U23I7, projeto SMS, top sys_top, MISTER_FB=1. Seeds 1 e 2, iguais às do experimento PSG físico anterior. Submódulo mist/mist-modules fixado em `9bf1ea25deffe35159cec8762a4f689c1db74a8b`. BUILD_DATE 261030 comum. Cada par difere somente em rtl/memory_decode.vhd; entre seeds somente SMS.qsf: SEED. Configurações originais de otimização, IP e constraints preservadas. Estágios map/fit/asm/sta explícitos, evitando preflow que altera data. Sem tuning ou novas seeds.

Scripts e hashes: [input_manifest.json](input_manifest.json), [workflow.log](workflow.log), [complete.diff](complete.diff), [results.json](results.json). Dados medidos nesta execução; resultados anteriores não foram usados como medições destes builds.

## Equivalência funcional

ModelSim Intel FPGA Starter executou os dois arquivos VHDL de produção em bibliotecas separadas, sem adaptar o RTL. [functional.log](functional.log): 327.680 comparações dos quatro outputs, sem divergência, e 65.536 verificações independentes do endereço esperado. [functional.js](functional.js) gera o [testbench](tb.vhd).

- Todos os 65.536 endereços de CPU em cada combinação binária de mapper_4pak/mapper_codies, incluindo 0038, 0066, 03FF, 0400 e fronteiras dos slots.
- Todas as 64 classes A(15:10), quatro combinações dos mappers e 256 valores de cada banco selecionável; bank1/bank2 usam bijeções distintas para detectar troca de slot.
- Sega: 0000–03FF permanece no banco físico zero; 0400–3FFF usa bank0. Codemasters e 4-PAK: todo o primeiro slot usa bank0, inclusive vetores. Slots 1/2 usam bank1/bank2; C000–FFFF também conserva o decode bank2, sem afirmar seleção efetiva de ROM nessa região.

A prova por decomposição complementa a simulação: os bits 12:0 são cópia inalterada de A; bit 13 é idêntico; a única diferença é fatorar o seletor 16 KB e condicionar a exceção do primeiro KB a mapper_4pak=0. Os ramos prioritários System E, multicart, linear/SC-3000/Dahjee, Janggun e Zemina/Nemesis são textualmente idênticos e continuam com a mesma prioridade. Demais saídas e lógica sequencial não mudaram. A independência entre bank0/1/2 decorre de apenas um banco ser selecionado em cada ramo; não se enumerou o produto cartesiano de todos os bancos.

Escopo: equivalência para entradas binárias estáveis e estados válidos de hardware; não é equivalência de nove valores std_logic. Exemplo: mapper_4pak=X, mapper_codies=0, A=0 e bank0 não zero produz banco zero no baseline e bank0 no candidato. Não foi feito teste em FPGA nem simulação de glitches/atrasos físicos.

## Resultados físicos

A = baseline; C = candidato; delta = C − A; percentual = 100 × delta/A. n/a para denominador zero. ALMs necessários = A−B+C da tabela do fitter, conferidos com o summary; ALMs colocados são a linha [A]. Registradores são o total fitted. Slack é o pior setup reportado entre os grupos.

### Seed 1

| Métrica | Baseline | Candidato | Delta | Delta % |
| --- | ---: | ---: | ---: | ---: |
| ALMs necessários | 26465 | 26607 | 142 | 0.54% |
| ALMs colocados | 31531 | 31679 | 148 | 0.47% |
| Registradores fitted | 35709 | 35704 | -5 | -0.01% |
| Registradores mapped | 34857 | 34857 | 0 | 0.00% |
| M10Ks | 487 | 487 | 0 | 0.00% |
| Bits de memória | 3809858 | 3809858 | 0 | 0.00% |
| Setup slack (ns) | 0.508 | 0.412 | -0.096 | -18.90% |
| Setup TNS (ns) | 0 | 0 | 0 | n/a |
| Hold slack (ns) | 0.144 | 0.207 | 0.063 | 43.75% |

Warnings normalizados novos: **0**; removidos: **0**. Critical warnings únicos normalizados A/C: **38/38**. Estrutura RAM idêntica: **true**.

### Seed 2

| Métrica | Baseline | Candidato | Delta | Delta % |
| --- | ---: | ---: | ---: | ---: |
| ALMs necessários | 26489 | 26599 | 110 | 0.42% |
| ALMs colocados | 31545 | 31651 | 106 | 0.34% |
| Registradores fitted | 35772 | 35811 | 39 | 0.11% |
| Registradores mapped | 34857 | 34857 | 0 | 0.00% |
| M10Ks | 487 | 487 | 0 | 0.00% |
| Bits de memória | 3809858 | 3809858 | 0 | 0.00% |
| Setup slack (ns) | 0.451 | 0.554 | 0.103 | 22.84% |
| Setup TNS (ns) | 0 | 0 | 0 | n/a |
| Hold slack (ns) | 0.243 | 0.215 | -0.028 | -11.52% |

Warnings normalizados novos: **0**; removidos: **0**. Critical warnings únicos normalizados A/C: **38/38**. Estrutura RAM idêntica: **true**.

## Warnings e cobertura temporal

Os critical warnings 18010/18061 tratam de power-up de registradores e opções de Power-Up Level ignoradas. A listagem completa por build e as diferenças normalizadas constam em results.json; contagens são mensagens únicas, não o número de repetições nos logs.

- seed1/A: IDs de warning 10036, 12241, 13024, 13050, 13051, 13410, 14284, 14285, 14320, 171167, 176250, 176251, 18010, 18061, 21300, 292013; cobertura incompleta reportada para setup, hold; 0 grupos com slack/TNS negativo.
- seed1/C: IDs de warning 10036, 12241, 13024, 13050, 13051, 13410, 14284, 14285, 14320, 171167, 176250, 176251, 18010, 18061, 21300, 292013; cobertura incompleta reportada para setup, hold; 0 grupos com slack/TNS negativo.
- seed2/A: IDs de warning 10036, 12241, 13024, 13050, 13051, 13410, 14284, 14285, 14320, 171167, 176250, 176251, 18010, 18061, 21300, 292013; cobertura incompleta reportada para setup, hold; 0 grupos com slack/TNS negativo.
- seed2/C: IDs de warning 10036, 12241, 13024, 13050, 13051, 13410, 14284, 14285, 14320, 171167, 176250, 176251, 18010, 18061, 21300, 292013; cobertura incompleta reportada para setup, hold; 0 grupos com slack/TNS negativo.

A ausência de violação nos grupos reportados não prova timing dos caminhos sem constraints. As constraints existentes foram preservadas para comparação controlada.

## Limites e reprodução

Dois pares de seeds medem sensibilidade observada de placement/routing, sem estimar significância estatística. Timing é o reportado pelas constraints existentes; avisos de caminhos não restringidos devem ser considerados, conforme results.json. O exit code bem-sucedido do Quartus não substitui a checagem de timing. GO significa prosseguir para teste em hardware, não aprovação automática de merge.

Para reproduzir, copie prepare.js, functional.js, build.ps1, check_inputs.js, measure.js e report.js para um novo diretório irmão em tests (preservando dependências relativas de measure.js). Execute node prepare.js, node functional.js, powershell -NoProfile -ExecutionPolicy Bypass -File build.ps1, node measure.js e node report.js. O runner recusa outputs existentes; não execute sobre estes resultados preservados.
