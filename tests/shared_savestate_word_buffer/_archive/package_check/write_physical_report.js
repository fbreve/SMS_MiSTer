const fs=require('fs'),p=require('path'),assert=require('assert');
const d=p.join(__dirname,'physical'),r=JSON.parse(fs.readFileSync(p.join(d,'results.json'),'utf8'));
assert(r.complete);
assert([1,2].every(s=>['baseline','candidate'].every(v=>r.builds[s][v].MLABbits===0)));
assert([1,2].every(s=>r.delta[s].placed>0&&r.delta[s].needed>0&&r.delta[s].setup<0),'Results changed: review the recommendation before replacing the report');
const n=x=>x.toLocaleString('pt-BR'),ns=x=>x.toLocaleString('pt-BR',{minimumFractionDigits:3,maximumFractionDigits:3});
let table='| Seed | Versão | ALMs necessários | ALMs colocados | FF mapeados | FF físicos | M10K | Setup ns | Hold ns |\n| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |\n';
for(const s of [1,2])for(const v of ['baseline','candidate']){const x=r.builds[s][v];table+=`| ${s} | ${v==='baseline'?'master':'experimental'} | ${n(x.needed)} | ${n(x.placed)} | ${n(x.mappedRegisters)} | ${n(x.registers)} | ${x.M10K} | ${ns(x.setup)} | ${ns(x.hold)} |\n`;}
let local='| Seed | Versão | ALMs necessários locais | ALMs colocados locais | ALUTs locais | FF locais |\n| --- | --- | ---: | ---: | ---: | ---: |\n';
for(const s of [1,2])for(const v of ['baseline','candidate']){const x=r.builds[s][v].savestatesFitted;local+=`| ${s} | ${v} | ${n(x.needed)} | ${n(x.placed)} | ${n(x.logicALUT)} | ${n(x.registers)} |\n`;}
let clocks='| Seed | Versão | Grupo de timing | Slack ns | TNS ns |\n| --- | --- | --- | ---: | ---: |\n';
for(const s of [1,2])for(const v of ['baseline','candidate'])for(const t of r.builds[s][v].timing)clocks+=`| ${s} | ${v} | ${t.type.replaceAll('|','\\|')} | ${ns(t.slack)} | ${ns(t.tns)} |\n`;
fs.writeFileSync(p.join(d,'timing.md'),clocks);
const report=`# Comparação física do buffer compartilhado — PR #3

Data: 30/10/2026, America/Sao_Paulo. Branch: experiment/shared-savestate-word-buffer. Baseline master: ${r.revisions.baseline}; RTL candidato: ${r.revisions.candidate}.

## Conclusão

**Recomendo descartar a otimização atual para integração.** A segurança funcional nos cenários testados permanece validada, mas o benefício físico não se confirmou: os dois pares usam mais ALMs necessários e colocados e apresentam menor folga de setup. A economia de 112 FF no mapping se mantém nas duas seeds; após fit, a economia é de 56 e 149 FF. M10K permanece em 488.

Não reverti o RTL nem alterei a master. A branch e as evidências permitem revisar o resultado; nenhuma síntese adicional, terceira seed, programação de placa ou merge foi realizada.

## Configuração e controle

A configuração foi identificada nos artefatos anteriores e confirmada pelo [PR #224 do PhaseMemory](https://github.com/MiSTer-devel/SMS_MiSTer/pull/224): Quartus Prime Lite 17.0.2 Build 602, dispositivo 5CSEBA6U23I7, revisão SMS, top sys_top, MISTER_FB=1, BUILD_DATE fixo 261014 e seeds 1 e 2. As configurações de desempenho, packing, QIP, SDC, IP e NUM_PARALLEL_PROCESSORS ALL são as originais. O AUTO do PhaseMemory já está na master e permaneceu igual nos dois lados.

Quatro árvores novas, somente com fontes Git, sem db/incremental_db, executaram map/fit/asm/sta sequencialmente: seed1 A/B e seed2 A/B. Cada par usou a mesma seed. Os caminhos de projeto Z:/baseline e Z:/candidate repetem o layout anterior. As etapas diretas pulam apenas o preflow que altera a data. Todos os 16 estágios terminaram com exit=0; o mapeamento temporário Z: foi removido ao final.

Os hashes dos seis executáveis coincidem com os do ensaio anterior. Os 203 arquivos do baseline são exatamente os do candidato PhaseMemory anterior. Os dois baselines frescos reproduziram todos os sete indicadores de controle anteriores: ALMs necessários/colocados, FF mapeados/físicos, M10K e slacks de setup/hold, com deltas zero. O baseline histórico foi apenas controle de reprodução, nunca substituto do build novo.

O manifesto confirma que A/B diferem apenas em rtl/savestates.sv; entre seeds, somente o SEED do SMS.qsf foi alterado. Nenhuma adaptação de simulação foi usada pelo Quartus.

## Resultados globais

${table}
| Candidato menos master | Seed 1 | Seed 2 |
| --- | ---: | ---: |
| ALMs necessários | +69 | +38 |
| ALMs colocados | +61 | +84 |
| FF mapeados | -112 | -112 |
| FF físicos | -56 | -149 |
| ALUTs de lógica | -128 | -125 |
| ALUTs de routing | -95 | +93 |
| M10K | 0 | 0 |
| Setup ns | -0,141 | -0,239 |
| Hold ns | -0,033 | +0,039 |

Os ALMs colocados aumentam cerca de 0,20% e 0,27%. Os slacks reportados continuam positivos e setup/hold TNS permanecem zero nos quatro builds. O pior grupo de setup é o clock HDMI nos quatro casos. A redução da margem de setup ocorre nas duas seeds e não deve ser escondida por um resultado médio. Os dados por grupo estão em [timing.md](timing.md).

Memória lógica: 3.810.182 bits em todos os builds; M10K: 488/553; memória MLAB: zero bits; DSP: 39. Não houve transferência de armazenamento para outro recurso de memória.

## Registradores, multiplexação e packing

O mapping confirma a previsão de 112 FF úteis economizados: os bits [7:0] dos acumuladores de 64 bits não são consumidos; 3×56 vira 56. A diferença nominal de 128 bits declarados seria uma estimativa excessiva do ganho de FF.

No mapping do controlador, ALUTs combinacionais passam de 4.100 para 3.941 e FF de 3.805 para 3.694, nas duas seeds. Portanto, a seleção adicional na entrada do buffer não anulou a economia lógica local: o compartilhamento também simplificou a lógica, incluindo o caminho de saída dos acumuladores. O FF global mapeado cai 112; as pequenas diferenças entre a contagem local e global refletem outras transformações do sintetizador.

${local}
As atribuições locais de ALMs são fracionárias e não representam sítios isoladamente removíveis. Embora o controlador economize cerca de 68 ALMs necessários em cada seed, a implementação global muda packing, duplicações e distribuição de lógica. O chip completo fica maior em ambas as seeds. Não é correto atribuir todo o aumento global diretamente ao novo mux, nem usar a economia local como se fosse economia global.

O resultado tampouco é uma regressão uniforme de routing: a utilização média total cai de 29,3% para 28,7%/28,2%; o pico total cai de 49,2% para 48,8% na seed1 e de 53,2% para 43,9% na seed2. Ainda assim, ALMs e setup pioram em ambos os pares. Contagens de FF, LUTs e ALMs medem aspectos distintos; não devem ser somadas como custos independentes.

## Warnings e limites

Warnings normalizados adicionados/removidos: 0/0 em cada par. Os quatro builds têm as mesmas classes e 38 mensagens críticas distintas no ledger, referentes a power-up: 18010 e 18061. Também permanecem os avisos de assignments ignorados 171167/176250/176251, de conectividade/PLL 12241/21300, de lógica não usada/removida e o 292013 sobre LogicLock exigir licença de assinatura no Lite. São avisos herdados, preservados integralmente, sem correções fora de escopo.

A normalização troca apenas os prefixos A/B por um marcador comum e ignora números de linha de savestates.sv para comparar mensagens equivalentes. Os relatórios originais comprimidos não foram normalizados.

As categorias herdadas de timing não totalmente constrained para setup e hold continuam nos quatro builds. Slack positivo reportado não equivale a fechamento completo de todas as interfaces. Dois pares de seeds em um dispositivo/configuração não provam uma distribuição estatística, mas ambos contradizem o benefício global pretendido. Nenhum teste de placa foi realizado.

## Testes e preservação

Os testes foram tornados autocontidos e reproduzidos: 16 operações save/load, 24 saves adicionais com System E e NVRAM 0/8/16/32 KB, e 8 saves com stalls antes/depois do registro das escritas, incluindo a última palavra dos seis estados DMA. Todos passaram com os mesmos totais de transações da auditoria. Os scripts usam commits fixos e um fixture incluído, sem depender de outros diretórios locais. O código de FM externo não faz parte desta validação. [Evidência funcional](../evidence/functional/results.json).

Foram excluídos do Git fontes geradas, bibliotecas do ModelSim, tentativas antigas, árvores de build, bancos do Quartus e bitstreams. Os scripts recebem os executáveis por parâmetro/variável de ambiente; não têm caminhos pessoais ou de instalação fixos. As regras de fim de linha preservam hashes de fontes e logs em clones novos.

[input_manifest.json](input_manifest.json) identifica todos os blobs e hashes de entrada; [tool_identity.json](tool_identity.json) identifica os executáveis; [pr224_reference.json](pr224_reference.json) registra os controles anteriores; [workflow.log](workflow.log) registra os estágios. [results.json](results.json) contém deltas, timing por grupo, recursos locais/globais, packing, routing, warnings e hashes dos 48 arquivos comprimidos completos. Os arquivos de evidência usam a pasta reports para evitar a exclusão global de output_files do Git. Cada entrada conserva o nome original do relatório.

O coletor releu e validou a descompressão dos 48 arquivos. A verificação independente das evidências passa sem bancos de implementação. Para reproduzir builds e análise, consulte [README.md](../README.md); para verificar apenas o pacote, execute node tests/shared_savestate_word_buffer/verify_evidence.js.

A recomendação é preservar estes resultados e encerrar a otimização atual como experimento sem ganho global demonstrado. Uma investigação de packing futura seria um novo trabalho; não foi misturada a esta comparação.
`;
fs.writeFileSync(p.join(d,'review.md'),report);
console.log('Wrote physical/review.md and physical/timing.md');
