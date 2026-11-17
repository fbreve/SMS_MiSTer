# Auditoria funcional do PR #3 — buffer compartilhado

A avaliação física posterior recomenda descartar a otimização para integração: [resultados das duas seeds](physical/review.md). A conclusão funcional abaixo permanece válida nos cenários testados.

Branch: `experiment/shared-savestate-word-buffer`. Original: `ab09fdf41221c9e3e77eee87264a125ba43021fe`; candidato: `28ead01f7f8709ddda5dc4a63206b9921cb757e0`. O GitHub confirmou PR aberto, draft, três commits e apenas `rtl/savestates.sv` alterado. A master permaneceu no mesmo hash. Esta etapa funcional precede a comparação física documentada separadamente; nenhum merge foi realizado.

## Resultado

Não foi encontrado defeito funcional introduzido pela unificação. Nenhuma correção de RTL necessária. Recomendo manter como experimento e avançar para comparação física controlada no Quartus quando autorizada; ainda não recomendo merge. Os resultados sustentam equivalência nos cenários exercitados, com argumento estrutural complementar; não constituem prova formal exaustiva.

## Revisão do diff e argumento de equivalência

O diff agregado tem 22 adições e 23 remoções. Os três commits incluem correções intermediárias de declaração e referências de NVRAM; o HEAD não contém buffers privados remanescentes. Contadores, estados, pipelines, latches de byte 7, handshake, portas e offsets DDRAM são iguais ao original.

Somente um estado de DMA executa por ciclo. Na entrada de cada transferência o acumulador correspondente passa a zero. Para bytes 0..6, as mesmas entradas e condições deslocam o mesmo conteúdo. Depois de sete bytes, os 56 bits superiores contêm toda a informação necessária. O oitavo byte é concatenado diretamente a esses bits. Nenhuma transferência necessita simultaneamente do acumulador de outra memória.

No último byte de VRAM→WRAM ou WRAM→NVRAM/VRAM2, duas atribuições não bloqueantes podem atingir `save_word_buf`: deslocamento e inicialização para zero. A última atribuição prevalece. Isso é seguro: os argumentos de dados da escrita usam o valor antigo; principalmente, o transporte já capturou o comando em DDRAM_DIN antes de permitir que a FSM avance. O acumulador antigo não é necessário depois da aceitação.

O mesmo princípio já existia entre bancos ativos/passivos da VRAM, que compartilhavam `vram_word_buf` no original.

## Transições revisadas

| Origem | Destino | Offset DDRAM do destino |
|---|---|---|
| VRAM SMS | WRAM | 0x901 |
| VRAM1 ativa System E | VRAM1 passiva | 0x1901 |
| VRAM1 passiva | WRAM de 16 KB | 0x901 |
| WRAM SMS com NVRAM | NVRAM de 8/16/32 KB | 0xD01 |
| WRAM SMS sem NVRAM | áudio | inalterado |
| WRAM System E | VRAM2 ativa | 0x1101 |
| VRAM2 ativa | VRAM2 passiva | 0x2101 |
| VRAM2 passiva ou NVRAM | áudio | inalterado |

VRAM1 ativa permanece em 0x101. Os bits 7 e 6 de mapper_snap selecionam independentemente os bancos ativos dos VDPs; as quatro combinações foram exercitadas. System E usa WRAM de 16 KB e segue para VRAM2, sem entrar em NVRAM.

## DDRAM_BUSY e escritas pendentes

Antes do byte 7, o avanço dos bytes é idêntico, sujeito a `ddram_step`. No byte 7 sem comando registrado, BUSY bloqueia emissão/deslocamento e o primeiro byte é preservado no latch específico da memória. Depois de registrar o comando, BUSY mantém WE, endereço, máscara e dados. O latch também recebe o byte 7 do comando registrado, evitando que o avanço da RAM síncrona altere a composição usada na aceitação. Com comando pendente não aceito, `ddram_step` é falso: a FSM não muda de memória nem zera o buffer. Quando aceito, o comando é liberado e a FSM pode avançar. Não há dependência posterior de DDRAM_DIN em relação ao acumulador.

## Testes executados

ModelSim Intel FPGA Starter 10.5b, RTL completo do controlador original e candidato lado a lado. Única adaptação de compilação: mover declarações de mapper_snap/evolution_snap para antes de seu uso, igualmente nas duas versões. Nenhuma lógica do controlador foi simplificada.

| Teste | Resultado | Ciclos | Escritas aceitas | Leituras |
|---|---|---:|---:|---:|
| Regressão existente adaptada de feedback_memory_auto/savestate_tb.sv | PASS | 8.482.683 | 57.580 | 57.564 |
| Matriz adicional, 24 saves | PASS | 2.518.648 | 181.956 | 0 |
| Stalls dirigidos, 8 saves | PASS | 1.393.111 | 60.652 | 0 |

A regressão existente faz oito pares save/load, SMS/System E, BIOS/cartucho, slots 0..3, com e sem BUSY. Verifica roundtrip CPU/VDP/PSG e compara as 58 saídas do controlador. As instâncias externas de FM foram retiradas: este teste não valida o chip FM e o texto histórico 'savestate/FM' no log é herdado do fixture.

A matriz adicional fornece bytes diferentes a VRAM1, VRAM2, WRAM e NVRAM a cada ciclo, inclusive durante stalls. Exercita NVRAM ausente/8/16/32 KB e todos os bancos System E, com BUSY periódico nos estados DMA. Compara as 58 saídas após a borda e também WE/RD/endereço/dados/máscara na borda que recebe a transação. Portanto compara dados/endereço realmente aceitos, além dos comandos ainda pendentes. Foram observados 376.239 ciclos de escrita pendente sob BUSY.

O teste dirigido injeta cinco ciclos de BUSY antes do registro de cada palavra DMA e nove depois do registro, mudando os dados de entrada durante a espera. Não apenas nas primeiras palavras: todos os seis estados têm cobertura explícita da última palavra antes da transição:

| Estado | Últimas palavras com stall antes / depois do registro |
|---|---:|
| VRAM1 ativa (17) | 8 / 8 |
| WRAM (18) | 8 / 8 |
| NVRAM (35) | 3 / 3 |
| VRAM2 ativa (45) | 4 / 4 |
| VRAM1 passiva (52) | 4 / 4 |
| VRAM2 passiva (53) | 4 / 4 |

Nesse teste houve 543.744 ciclos de escrita registrada retida e 228 transições de estado. Os três testes terminaram sem erros nem warnings. A reprodução autocontida e seus logs estão em evidence/functional/. git diff --check também passou.

Reprodução atual: consulte README.md e execute run.ps1 com VSIM_EXE configurado ou -Vsim. O pacote é autocontido; usa os dois commits fixos e não depende de outros diretórios de testes.

## Recursos e limites

Economia nominal declarada: 192→64 bits, ou 128 bits. Porém os bits [7:0] de cada acumulador não alimentam nenhum consumidor: apenas [63:8] é lido, inclusive no realimentador do deslocamento. Uma ferramenta que elimine bits mortos deve inferir 168→56 bits úteis, economia potencial de 112 flip-flops, antes de outros passes de otimização. Não confundir isso com 112 ALMs.

O novo acumulador exige selecionar o byte de VRAM/WRAM/NVRAM e combinar enables e clears das três rotas. Em compensação, o multiplexador de saída de 56 bits entre três acumuladores pode desaparecer. A direção do resultado físico não pode ser determinada pela contagem de registradores: LUTs, packing, fanout e caminhos de entrada/enable podem anular a economia ou piorar timing. Não foi usada síntese para sustentar um número de ALMs.

Limites: comparação diferencial, sem prova formal e sem oracle independente do conteúdo integral da RAM. Os bytes variáveis são estímulos de interface deliberados para expor retenção incorreta, não um modelo completo de RAM física; defeitos preexistentes comuns às duas versões não são excluídos. Não foi executada a totalidade dos numerosos testes históricos do repositório, nem teste de placa. Ainda faltam área e timing físicos em bases, constraints e seeds iguais.

Recomendação: manter o RTL atual sem novas refatorações; realizar depois A/B físico com o mesmo baseline e seeds, verificando ALMs, registradores, memória e folga dos caminhos afetados. Aceitar a otimização apenas se houver benefício físico mensurável e timing aceitável. Se o ganho desaparecer, descartar a unificação para evitar custo de manutenção sem retorno.


## Preservação e reprodução atual

Os geradores foram revistos para usar commits fixos e um fixture incluído no pacote. As tentativas antigas, bibliotecas do ModelSim e fontes geradas ficam fora do Git. A comparação física autorizada posteriormente é documentada em physical/review.md.
