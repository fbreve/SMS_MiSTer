# Limpeza de worktrees experimentais — 17/11/2026

Concluída: 20 worktrees removidas com git worktree remove --force somente depois da preservação e verificação remota. Nenhum clone independente original foi encontrado em tests. O repositório vazio criado para verificar o download do GitHub foi removido separadamente após a verificação.

## Espaço

| Medida | Antes | Depois | Recuperado |
|---|---:|---:|---:|
| Arquivos em tests (tamanho lógico) | 41.036 GB | 38.008 GB | 3.027 GB |
| Espaço livre no volume C: | 683.068 GB | 685.375 GB | 2.307 GB |

As worktrees removidas somavam 3.128 GB. A diferença líquida em tests inclui os novos ZIPs, manifestos e relatórios. A variação do espaço livre inclui o crescimento de objetos Git e possíveis atividades concorrentes do sistema; não equivale exatamente ao tamanho lógico removido. Nenhum hard link foi criado. A leitura inicial de Get-PSDrive no sandbox retornou null; a medição válida foi feita por DriveInfo antes do arquivamento/remoção.

## Publicação verificada

Push atômico de 21 branches novas no fork, sem force push. Verificação por ls-remote seguida de fetch depth=2 em banco de objetos vazio, sem alternates locais, comparação de árvores e 18947 arquivos, e git fsck --full. Os HEADs originais também foram encontrados no download; 9873761503510e4b2c7e06600bf5515344235c2f e 66ef9f3bb0b69e3eb3f62ff285c0d1f7eadad799 estão preservados como ancestrais. As referências remotas existentes permaneceram iguais.

Os campos localOnly em before.json descrevem candidatos não alcançáveis pelas refs origin locais da auditoria inicial; a prova de publicação final é remote_verification.json e o download independente, não essas refs locais.

| Worktree removida (relativa a tests) | Branch publicada | Commit |
|---|---|---|
| feedback_memory_auto/worktree | [archive/20261117/feedback_memory_auto-worktree](https://github.com/fbreve/SMS_MiSTer/tree/archive/20261117/feedback_memory_auto-worktree) | [5ebb01bd5bfb](https://github.com/fbreve/SMS_MiSTer/commit/5ebb01bd5bfb78ff57e9c4f80e02cbc5981882f5) |
| fm_complete_structure_20261116/worktree | [archive/20261117/fm_complete_structure_20261116-worktree](https://github.com/fbreve/SMS_MiSTer/tree/archive/20261117/fm_complete_structure_20261116-worktree) | [222f9ea2f215](https://github.com/fbreve/SMS_MiSTer/commit/222f9ea2f2159f200b36eae0bdc935499bdfe7d2) |
| fm_state_reduction_20261116/worktree | [archive/20261117/fm_state_reduction_20261116-worktree](https://github.com/fbreve/SMS_MiSTer/tree/archive/20261117/fm_state_reduction_20261116-worktree) | [8e0d755d9a63](https://github.com/fbreve/SMS_MiSTer/commit/8e0d755d9a63128de1bb241bd599d81a44a49768) |
| psg_simplification/B | [archive/20261117/psg_simplification-B](https://github.com/fbreve/SMS_MiSTer/tree/archive/20261117/psg_simplification-B) | [6cd8df2e0a96](https://github.com/fbreve/SMS_MiSTer/commit/6cd8df2e0a9688196b732d8088b88619c0395c6d) |
| psg_simplification/C | [archive/20261117/psg_simplification-C](https://github.com/fbreve/SMS_MiSTer/tree/archive/20261117/psg_simplification-C) | [00a3efa320d7](https://github.com/fbreve/SMS_MiSTer/commit/00a3efa320d7ee9b37ff344ee9ef58f7d59dbfb4) |
| register_memory_auto/worktree | [archive/20261117/register_memory_auto-worktree](https://github.com/fbreve/SMS_MiSTer/tree/archive/20261117/register_memory_auto-worktree) | [7bc68a6a08c0](https://github.com/fbreve/SMS_MiSTer/commit/7bc68a6a08c0aa3810e06badb233e65c43ac563d) |
| register_memory_local_control/worktree | [archive/20261117/register_memory_local_control-worktree](https://github.com/fbreve/SMS_MiSTer/tree/archive/20261117/register_memory_local_control-worktree) | [9e2cf8d6feea](https://github.com/fbreve/SMS_MiSTer/commit/9e2cf8d6feeac09cf0a6137ec704331c241f3296) |
| ym2413_c1_mixer_omission/worktree | [archive/20261117/ym2413_c1_mixer_omission-worktree](https://github.com/fbreve/SMS_MiSTer/tree/archive/20261117/ym2413_c1_mixer_omission-worktree) | [aacc90567035](https://github.com/fbreve/SMS_MiSTer/commit/aacc90567035bda06264b385d108799df4b2b8c3) |
| ym2413_feedbackmemory_mlab/worktree | [archive/20261117/ym2413_feedbackmemory_mlab-worktree](https://github.com/fbreve/SMS_MiSTer/tree/archive/20261117/ym2413_feedbackmemory_mlab-worktree) | [89b9fb90aed0](https://github.com/fbreve/SMS_MiSTer/commit/89b9fb90aed0466877b69b5432caf3487322db1f) |
| ym2413_optimized_integration/worktree | [archive/20261117/ym2413_optimized_integration-worktree](https://github.com/fbreve/SMS_MiSTer/tree/archive/20261117/ym2413_optimized_integration-worktree) | [3927d80e08c4](https://github.com/fbreve/SMS_MiSTer/commit/3927d80e08c405bb8736b92ffbb358e7f942c7e1) |
| ym2413_outputmemory_mlab/worktree | [archive/20261117/ym2413_outputmemory_mlab-worktree](https://github.com/fbreve/SMS_MiSTer/tree/archive/20261117/ym2413_outputmemory_mlab-worktree) | [60eb811e383f](https://github.com/fbreve/SMS_MiSTer/commit/60eb811e383f456451c6f5d89e5db5c897a73898) |
| ym2413_outputmemory_mlab_guarded/worktree | [archive/20261117/ym2413_outputmemory_mlab_guarded-worktree](https://github.com/fbreve/SMS_MiSTer/tree/archive/20261117/ym2413_outputmemory_mlab_guarded-worktree) | [8a8c70a341c7](https://github.com/fbreve/SMS_MiSTer/commit/8a8c70a341c7a8baeb0bdec77fc9fc713ac5d660) |
| ym2413_public_v1_integration/worktree | [archive/20261117/ym2413_public_v1_integration-worktree](https://github.com/fbreve/SMS_MiSTer/tree/archive/20261117/ym2413_public_v1_integration-worktree) | [1a2712cf4c8c](https://github.com/fbreve/SMS_MiSTer/commit/1a2712cf4c8cd5789181854ec01172b67328dfd7) |
| ym2413_registermemory_auto/worktree | [archive/20261117/ym2413_registermemory_auto-worktree](https://github.com/fbreve/SMS_MiSTer/tree/archive/20261117/ym2413_registermemory_auto-worktree) | [08e6ba58e165](https://github.com/fbreve/SMS_MiSTer/commit/08e6ba58e1653e35abb0375f742e16c4ef107682) |
| ym2413_registermemory_mlab/worktree | [archive/20261117/ym2413_registermemory_mlab-worktree](https://github.com/fbreve/SMS_MiSTer/tree/archive/20261117/ym2413_registermemory_mlab-worktree) | [d9fab48c971b](https://github.com/fbreve/SMS_MiSTer/commit/d9fab48c971b597150dfbe11e014e5bcc5b1570c) |
| ym2413_selfhealing_combined/worktree | [archive/20261117/ym2413_selfhealing_combined-worktree](https://github.com/fbreve/SMS_MiSTer/tree/archive/20261117/ym2413_selfhealing_combined-worktree) | [9042ea3164a5](https://github.com/fbreve/SMS_MiSTer/commit/9042ea3164a565ddcd7475fc30041d5cbc6857e3) |
| ym2413_selfhealing_mix/worktree | [archive/20261117/ym2413_selfhealing_mix-worktree](https://github.com/fbreve/SMS_MiSTer/tree/archive/20261117/ym2413_selfhealing_mix-worktree) | [54311d94696c](https://github.com/fbreve/SMS_MiSTer/commit/54311d94696c47eaf9d46b4c87cc6bc39b7d73c0) |
| ym2413_selfhealing_mixout/worktree | [archive/20261117/ym2413_selfhealing_mixout-worktree](https://github.com/fbreve/SMS_MiSTer/tree/archive/20261117/ym2413_selfhealing_mixout-worktree) | [9cfad1c7de38](https://github.com/fbreve/SMS_MiSTer/commit/9cfad1c7de38c1d8bdd7c09bc5302a30a7fcbd02) |
| ym2413_upstream_v1_audit/worktree | [archive/20261117/ym2413_upstream_v1_audit-worktree](https://github.com/fbreve/SMS_MiSTer/tree/archive/20261117/ym2413_upstream_v1_audit-worktree) | [da93390bb3a0](https://github.com/fbreve/SMS_MiSTer/commit/da93390bb3a0f89034aca8a3b1369b3cc2bf3e48) |
| ym2413_v19_fullstate/worktree | [archive/20261117/ym2413_v19_fullstate-worktree](https://github.com/fbreve/SMS_MiSTer/tree/archive/20261117/ym2413_v19_fullstate-worktree) | [75c2a24e957c](https://github.com/fbreve/SMS_MiSTer/commit/75c2a24e957cdd2bd63e38c75b20905a97f592cd) |

Evidências externas consolidadas: [archive/20261117/consolidated-evidence](https://github.com/fbreve/SMS_MiSTer/tree/archive/20261117/consolidated-evidence), commit [cf6720e39ea0816f85f11dc8a7ebc817d0a5afe7](https://github.com/fbreve/SMS_MiSTer/commit/cf6720e39ea0816f85f11dc8a7ebc817d0a5afe7); 14810 arquivos selecionados (0.198 GB de texto não comprimido), incluindo FM/PR #227, Ys, relatórios, scripts, patches, métricas e manifestos. Todos os diretórios de resultados externos foram mantidos; 111372 arquivos originais externos às worktrees conferidos por presença e tamanho, sem divergências.

## Preservação e classificação

- Código rastreado sem alterações: recuperável pelos HEADs originais, preservados como pais dos snapshots. Releases/RBFs já pertencentes ao histórico não foram adicionados novamente.
- Mudanças rastreadas, fontes ignoradas, scripts/testbenches, documentação, patches, JSONs e métricas pequenas: publicados nas branches de cada experimento, nos caminhos originais; os manifestos ficam em experiments/archive_20261117/<experimento>/manifest.json.
- Logs pequenos foram mantidos como evidência; logs maiores, dados binários e CSVs brutos extensos foram arquivados fora das worktrees, nunca adicionados ao Git.
- Bibliotecas compiladas de simulador, bancos de trabalho e caches gerados: descartados, com caminhos, hashes e justificativa nos manifestos. Arquivos não rastreados não foram classificados automaticamente como temporários.
- ZIPs e manifestos preexistentes não foram excluídos. Os novos arquivos abaixo tiveram cada entrada descompactada em stream e verificada por comprimento e SHA-256 antes da remoção. Hashes dos arquivos publicados descrevem os bytes originais; o Git aplica sua normalização normal de finais de linha ao armazenar texto.

| ZIP local em raw_archives/ | Entradas | Bytes comprimidos | SHA-256 |
|---|---:|---:|---|
| ym2413_feedbackmemory_mlab-worktree.zip | 1 | 7146 | bc3ae7bc355007b2e9cedc946b78824a6e29d11ba705508118faffcbf41df474 |
| ym2413_outputmemory_mlab-worktree.zip | 1 | 7160 | ec4efce8eb27817b42ad5594473984d3d4b26da0679b5f71dc22a0585fdb5c67 |
| ym2413_registermemory_auto-worktree.zip | 1 | 7075 | c7aa86eca6e8f8dc3f9e814ab0c8ddcf94443f0f5436788644cbfd1b0f6f2c89 |
| ym2413_selfhealing_combined-worktree.zip | 3 | 56686 | 43e425b23e9b4eed99e5e929b5a3d5066227e45abb9b04a3130d467c6dba3832 |
| ym2413_selfhealing_mix-worktree.zip | 16 | 7352758 | d5995ec0cb7771175efc8f4905794c357fe1a9fd0cb4e18f3c1bde4ade9311bd |
| ym2413_selfhealing_mixout-worktree.zip | 77 | 69827343 | 666a9d74238fca086427a396bfa3ea352da3c0ebb405697ae559f9a03bec3cfa |
| ym2413_v19_fullstate-worktree.zip | 1 | 6454 | cc38ebd3c034d28e708b44410e536bfd2e673fdfd7af214f609cf00dcef0e8d3 |

Total: 100 arquivos brutos em sete ZIPs, 77264622 bytes comprimidos. A localização local e os hashes estão em raw_archive_verification.json; a lista de entradas e hashes originais está nos manifestos por experimento. Para reproduzir, faça checkout da branch do experimento e extraia o ZIP correspondente na raiz desse checkout, preservando os caminhos internos, então use os scripts e relatórios do experimento. Caminhos absolutos históricos dos scripts podem exigir ajuste para a máquina atual. Arquivamento não significa nova validação funcional dos experimentos: os resultados NO-GO e limitações científicas originais continuam válidos.

## Integridade e pendências

- Apenas o checkout principal permanece em git worktree list. HEAD principal ff70cb70ce9724d97cd5cc2946c14ba21c809a96; master 66f16d5c656fd8906d62570da4d258875bcee684; nenhum checkout, reset, clean, merge ou alteração de PR foi realizado.
- git diff e git diff --cached vazios. Status principal mantém apenas os itens não rastreados preexistentes SMS_ym2413_test_s1.rbf e tests/.
- git fsck --full --no-reflogs terminou com código 0; objetos dangling eventualmente listados são objetos locais não alcançados, não corrupção.
- Não há worktree pendente. Os ZIPs brutos são arquivos locais preservados para sincronização pelo Syncthing; não foram enviados ao GitHub. Uma cópia off-site pode ser feita desses sete ZIPs e manifestos caso seja desejada; o estado da sincronização não foi verificado.
- A publicação posterior da auditoria e deste relatório fica na branch archive/20261117/cleanup-report, sem alterar as 21 branches já verificadas.

A branch cleanup-report também preserva 19561 arquivos adicionais de fontes, testbenches e código em subdiretórios externos profundos, relacionados em additional_sources_manifest.json. Cópias repetidas compartilham objetos Git pelo conteúdo, sem hard links no filesystem.

A primeira execução de fsck encontrou referências inválidas no cache commit-graph antigo (código 16). Os objetos foram verificados com o uso desse cache desabilitado; o cache antigo foi movido para commit_graph_cache_backup e um novo foi gerado dos commits alcançáveis. A escrita e a verificação do novo commit-graph terminaram com código 0, assim como o fsck final. Não foi necessário alterar ou remover qualquer commit.
