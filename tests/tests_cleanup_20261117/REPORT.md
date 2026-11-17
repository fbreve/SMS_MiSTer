# Auditoria e limpeza integral de tests — 17/11/2026

Limpeza concluída. Nenhum arquivo científico único foi descartado. As conclusões originais dos estudos YM2413/FM, PR #227, self-healing e SRAM de Ys foram mantidas. Nenhuma branch histórica, master ou PR foi alterado; este trabalho é publicado em uma nova branch archive/20261117/tests-storage-cleanup.

## Espaço medido

| Medida | Antes | Depois da limpeza | Recuperado |
|---|---:|---:|---:|
| Tamanho lógico de tests | 38.008 GB | 7.325 GB | 30.683 GB |
| Espaço livre real do volume C: | 684.844 GB | 712.826 GB | 27.983 GB |
| Arquivos inventariados | 111452 | 77505 | 33947 a menos |

Redução lógica de 80.7%. Medições são snapshots após as exclusões e antes do empacotamento/publicação final da auditoria; os pequenos arquivos finais de auditoria e os novos objetos Git acrescentam algum espaço. A variação do volume também inclui atividades concorrentes do sistema e alocação NTFS. Inventários são disponibilizados no GitHub em .json.gz/.csv.gz para evitar grandes arquivos de texto repetitivos.

## Inventário e origem

O inventário inicial cobriu 111452 arquivos, inclusive ignorados e não rastreados. inventory_before/after descrevem caminho, tamanho, extensão, experimento de origem, função e status Git. directories_before/after agregam todos os níveis de diretório; summary_before/after agregam diretório de experimento, extensão, função e status. Os manifestos e relatórios de cada experimento continuam sendo a autoridade para revisão de origem, versão, seeds, inputs e limitações científicas.

Nenhum clone ou worktree independente válido permaneceu dentro de tests. O único marcador .git inicial era um arquivo vazio do cache uv, que não era um repositório. git worktree list continua mostrando somente o checkout principal. Arquivos não rastreados ou ignorados não foram classificados como descartáveis por esse motivo.

## Exclusões definitivas comprovadas

| Categoria | Arquivos | Bytes removidos | Justificativa/recuperação |
|---|---:|---:|---|
| duplicate-rbf | 46 | 190331352 | Cópia canônica SMS preservada e conferida por SHA-256; rbf_aliases.json. |
| public-release | 3658 | 11260831160 | Disponibilidade pública anônima e SHA-256 verificados; URLs fixadas ao commit em public_releases.json. |
| compiled-modelsim | 3434 | 1737365197 | Bibliotecas reconhecidas por _info/_vmake e componentes _lib*.qdb/qpg/qtl; HDL e scripts de compilação preservados. |
| compiled-native | 95 | 262365280 | Objetos, headers compilados e executáveis Verilator/GCC; fontes e scripts de build preservados. |
| public-tool | 15419 | 2753773794 | OSS CAD Suite oficial 20261116, digest da distribuição e componentes registrados; instalação compartilhada sob demanda. |
| python-bytecode | 2 | 9460 | Bytecode regenerável a partir de fontes. |
| python-package-cache | 6 | 2017 | Cache uv sem fontes científicas exclusivas. |
| duplicate-log | 2404 | 6358212 | Igualdade byte a byte por SHA-256; log_aliases.json preserva caminho, tamanho, hash e timestamp original. |
| duplicate-tool | 120 | 75932413 | Cópia GHDL idêntica à cópia canônica completa; todos os 120 arquivos conferidos; tool_aliases.json. |

Os nomes, hashes, tamanhos e justificativas de cada exclusão estão em deletions.json. A primeira remoção de diretórios vazios reportou 2039 diretórios gerados; 2037 deles são reconstruíveis a partir dos diretórios que tinham arquivos no inventário inicial (empty_directories_removed.json). Diretórios vazios não representam dados científicos removidos.

### Releases e RBFs

Foram recalculados os SHA-256 das 3856 RBFs iniciais, que ocupavam 12,072 GB. Os 36 releases SMS distintos foram efetivamente baixados sem autenticação do upstream público, com comparação de conteúdo e tamanho, no commit registrado em public_releases.json. Foram removidas 3658 cópias desses releases e 46 duplicatas exatas de builds. Três RBFs adicionais eram bitstreams auxiliares openFPGALoader pertencentes ao pacote OSS CAD Suite, removidos junto com a ferramenta pública.

Restam **149 builds SMS distintos**, cada qual com SHA-256 recalculado e preservado em retained_rbfs.json. Não se afirma que todos são qualificados em hardware: são versões experimentais únicas mantidas para reprodução e auditoria. A build de Ys qualificada em hardware permanece exatamente em tests/ys_fm227_validation_20261115/release/SMS_ys_sram_fm227_69edeb48_p8e59c978_s1.rbf, SHA-256 **3ebda245e566f22ed2ec1b363359b58f9f83804ad83c5ce83626d431eef103bd**, sem reconstrução, renomeação ou alteração.

## Preservação compactada

16716 caminhos originais (20.025 GB) foram preservados em 7849 objetos gzip distintos, totalizando 5.523 GB. A compressão foi usada somente quando vantajosa; arquivos incompressíveis continuam em seus caminhos. Cada objeto teve o hash dos bytes comprimidos e o SHA-256 de todo o conteúdo descompactado conferidos antes de excluir o original. A verificação integral final também passou para os 7849 objetos.

compression.jsonl relaciona cada caminho original aos hashes e ao objeto em tests/_artifacts/gzip. A persistência desse registro ocorreu antes da exclusão de cada original. Compartilhar o mesmo objeto comprimido por conteúdo não cria hard links. Logs de stdout que não eram exatamente iguais não foram tratados como duplicatas por suposição: seus bytes relevantes foram mantidos, geralmente compactados.

Foram analisados .bin, .csv, .log, .rpt, .sof, .tar, .dat, .hex, netlists e outros arquivos por contexto. Capturas, payloads, dumps relevantes, SOFs e arquivos tar de fontes foram preservados compactados, sem publicá-los como dados volumosos no Git. Metadados pequenos, fontes, scripts, testbenches, diffs e relatórios consolidados permanecem disponíveis.

Os bancos fitted do Quartus mereceram tratamento distinto de bibliotecas compiladas regeneráveis: **4.461 GB de objetos comprimidos** mantêm os resultados físicos exatos para consultas posteriores, além dos componentes que não ganhavam com compressão. Eles não foram eliminados com base na hipótese de que uma nova compilação reproduziria exatamente a colocação/roteamento. Fontes, settings, seeds e relatórios correspondentes foram conservados. Isso explica boa parte do espaço remanescente; não há meta artificial de tamanho que justifique perder essa evidência.

Os **19 ZIPs preexistentes foram mantidos e seus SHA-256 conferidos**. Os sete ZIPs científicos da limpeza anterior também tiveram cada entrada descompactada em stream e comparada ao tamanho e SHA-256 dos manifestos originais. Ambos os ZIPs GHDL foram preservados mesmo sendo cópias da distribuição. Nenhum manifesto anterior foi excluído.

## Scripts e prevenção de novo acúmulo

58 scripts foram ajustados, com hashes antes/depois em script_changes.json e cópias anteriores em script_before/. A edição limita a preparação/materialização a fontes úteis ao build: git archive, extração de arquivos antigos e cópias baseadas em ls-tree/manifestos deixam de incluir releases/. A checagem de arquivo exportado confirmou que SMS.sv e rtl/savestates.sv continuam presentes e releases/ fica ausente. RTL, constraints, seeds, protocolos e conclusões dos experimentos não foram editados.

Os builds de convergência localizam o OSS CAD Suite em tests/_tools por shared-tools.cjs, com download sob demanda, SHA-256 oficial da distribuição e verificação do executável Verilator. getRelease(nome) verifica e reutiliza o diretório releases/ principal ou uma única cópia em tests/_shared/releases. A cópia GHDL completa já compartilhada pelos scripts de FM foi mantida; a outra cópia idêntica não era referenciada pelos scripts atuais.

Os novos artifact-store.cjs e run-experiment.cjs permitem recuperar bytes originais ou executar análises Node com leitura dos caminhos históricos. A compatibilidade cobre readFileSync, statSync, existsSync e readdirSync; ferramentas nativas, Python, PowerShell e APIs assíncronas devem receber antes os arquivos necessários com hydrate. Detalhes e comandos estão em [STORAGE.md](../STORAGE.md). Nenhuma configuração do Syncthing ou procedimento específico de outra máquina é necessário para preservar os dados: objetos comuns e manifestos são arquivos normais sincronizados.

A revisão de tests/.gitignore distingue caches públicos e objetos científicos locais dos manifestos versionáveis; permite CSV/XML/summaries/listas .f fora de diretórios de build. A regra de Git não controla Syncthing: _artifacts/gzip deve continuar no acervo sincronizado.

## Validação, publicação e pendências

- git fsck --full --no-reflogs --no-dangling terminou com código 0. HEAD principal ff70cb70ce9724d97cd5cc2946c14ba21c809a96 e master 66f16d5c656fd8906d62570da4d258875bcee684 continuam iguais. git diff e git diff --cached permanecem vazios. Status principal conserva os itens não rastreados SMS_ym2413_test_s1.rbf e tests/.
- retention_verification.json contabiliza todos os arquivos originais: nenhuma ausência ou modificação sem justificativa; nenhum arquivo rastreado removido. Os hashes dos 149 RBFs SMS e das cópias canônicas foram verificados.
- Todos os scripts JavaScript editados passaram em node --check; os dois PowerShell editados passaram pelo parser. Foram exercitados a recuperação byte a byte de um arquivo, a leitura transparente de arquivo comprimido e de log duplicado, a resolução do release compartilhado e o filtro de exportação de fontes. Não se reexecutaram campanhas científicas nem builds físicos: esta limpeza não constitui nova validação de hardware ou das hipóteses dos experimentos.
- As 22 branches da limpeza anterior continuam publicadas, com refs inalteradas. Este relatório, scripts e manifestos são publicados em uma **nova** branch [archive/20261117/tests-storage-cleanup](https://github.com/fbreve/SMS_MiSTer/tree/archive/20261117/tests-storage-cleanup), com push normal e verificação remota. ZIPs, RBFs e objetos científicos volumosos não são enviados ao GitHub.
- Sem pendência de dados científicos sem preservação. Os bancos fitted exatos e os demais objetos compactados são retenções deliberadas para auditoria/reprodução. O estado da sincronização do Syncthing e uma eventual cópia off-site não foram verificados.
