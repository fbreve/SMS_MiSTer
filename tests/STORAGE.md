# Armazenamento e reprodução dos experimentos

A limpeza de 17/11/2026 preserva as conclusões e os relatórios originais. O inventário, os hashes, as justificativas e o relatório ficam em `tests_cleanup_20261117/`. As worktrees removidas anteriormente continuam disponíveis nas branches listadas em `worktree_cleanup_20261117/REPORT.md`.

## Evidências compactadas

`_artifacts/gzip/<SHA-256-original>.gz` contém dados científicos, relatórios extensos, capturas, payloads, SOFs e bancos fitted exatos. `tests_cleanup_20261117/compression.jsonl` relaciona cada caminho original ao objeto comprimido, com ambos os hashes e tamanhos. Vários caminhos iguais por conteúdo usam um único objeto comum. Não são hard links.

Esse acervo deve continuar sincronizado pelo Syncthing. A exclusão dele do Git não o torna um cache descartável. Os ZIPs de arquivamento anteriores e seus manifestos foram mantidos.

Verificação integral:

```powershell
node tests/artifact-store.cjs verify
```

Para recuperar um arquivo ou os arquivos comprimidos de um experimento:

```powershell
node tests/artifact-store.cjs restore tests/EXPERIMENTO/caminho/arquivo.log
node tests/artifact-store.cjs hydrate tests/EXPERIMENTO
```

Os bytes originais são conferidos por SHA-256. `hydrate` também pode ser usado em subdiretórios, por exemplo `tests/pr227_matched_20261114/seed1/candidate/db`. Ele não baixa releases nem recria automaticamente as RBFs duplicadas.

Análises Node que usam `readFileSync`, `statSync`, `existsSync` e `readdirSync` podem consultar os caminhos históricos sem expandir os dados:

```powershell
node tests/run-experiment.cjs tests/EXPERIMENTO/analysis.js
```

Esse adaptador cobre essas operações síncronas de leitura; não virtualiza o filesystem para ferramentas nativas, Python, PowerShell ou APIs assíncronas. Para esses casos, recupere antes os arquivos do experimento e de suas dependências com `hydrate`. Reconstrua as bibliotecas ModelSim pelos `compile.do` e os executáveis pelos scripts de build preservados. Respeite os guardas de cada experimento contra sobrescrever evidências: uma nova campanha deve usar uma cópia isolada.

## Builds e duplicatas

As RBFs SMS únicas foram mantidas em seus caminhos de referência, incluindo a build de Ys qualificada em hardware, SHA-256 `3ebda245e566f22ed2ec1b363359b58f9f83804ad83c5ce83626d431eef103bd`. `retained_rbfs.json` lista as cópias canônicas. `rbf_aliases.json` e `log_aliases.json` registram os caminhos de duplicatas exatas removidas. O adaptador de análise resolve esses caminhos; se uma ferramenta externa exigir uma cópia física específica:

```powershell
node tests/artifact-store.cjs alias tests/CAMINHO-ANTIGO
```

Os bancos Quartus únicos foram preservados byte por byte, compactados quando isso economizava espaço, para possibilitar consultas sobre o fitting histórico exato. Isso não equivale a afirmar que uma recompilação futura produzirá a mesma colocação e roteamento.

## Releases e ferramentas públicas

`public_releases.json` contém URLs fixadas ao commit público, tamanhos e SHA-256 dos 36 releases. Novos snapshots de fontes excluem `releases/`. Para localizar um release, use `require('../shared-tools.cjs').getRelease(nome)` a partir de scripts diretamente dentro de um experimento: ele verifica primeiro `releases/` do repositório e depois o cache compartilhado `tests/_shared/releases/`. Se necessário, baixa e verifica uma única cópia compartilhada.

O OSS CAD Suite 20261116 tem digest oficial registrado em `tool_public_verification.json`. Os builds de convergência usam `tests/_tools/oss-cad-suite`, instalado sob demanda com verificação do arquivo de distribuição e do executável Verilator original:

```powershell
node tests/shared-tools.cjs install
```

Uma cópia GHDL completa permanece em `ym2413_selfhealing_combined/tools/ghdl6`, caminho já usado pelos scripts de FM. A cópia idêntica em `ym2413_selfhealing_mix` foi eliminada após conferir cada arquivo; `tool_aliases.json` permite recuperar os caminhos antigos. Ambos os ZIPs de distribuição foram mantidos. A preparação de fontes e as cópias baseadas em manifestos agora excluem releases públicos. RTL, seeds, constraints e condições científicas dos experimentos não foram alterados.

## Git e publicação

`tests/.gitignore` distingue caches de ferramentas e os objetos binários locais de seus manifestos. Metadados CSV, XML, summaries e listas de compilação `.f` fora de diretórios de build deixam de ser omitidos apenas por extensão. Fontes, scripts, patches, relatórios consolidados e manifestos pertencem ao Git; dados científicos volumosos pertencem ao acervo local verificado. A limpeza não muda o comportamento do Syncthing por configuração local, e não depende de links NTFS.
