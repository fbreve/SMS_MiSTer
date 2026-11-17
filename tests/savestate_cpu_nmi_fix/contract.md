# F16 implementation contract

Baseline d1df590, existing branch fix/savestate-cpu-nmi. Both authoritative reports were read in full before production edits.

At accepted MC1/T2 T, store the unchanged pre-edge architectural registers and normalized `(P | (Old & !NMI_n), C, NMI_n)`. P=NMI_s, C=NMICycle. The final component is historical sampled Old, not a host-output restore value. The captured pulse therefore survives a later released input; a continuously low level does not become another edge. GG/IO remain post-T snapshots. Three bits suffice; there is no fourth sampled-event bit.

During LOAD, hold sampling before GG/CPU restore. DIRSet and GG set restore architecture and post-T source together. After DIRSet is deasserted, and after GG output settles, install the saved triplet with CPU CEN0. Do not preserve Q. Return CPU memory-read ownership, then perform ordinary-rate CPU-only T1/T2 restart while sampling and GG remain held. Release sampling on the clock following historical T2, so any GG fall produced by G(T) is first seen at logical T+1. No other DIRSet may erase the installed triplet.

Current external input remains external. Legacy snapshots clear P/C and normalize Old from the settled current input; their lost historical events cannot be recovered. Valid v12 uses saved normalized history. Malformed v12 is rejected before guest-state writes. Proposed word5 bits40:38 map P/C/Old, bits63:41 zero, bits37:0 retain architecture; tag48430C/subtype3 inherits all v1-v11 meanings.

Implementation uses a small T80s restart phase controller; it holds the sampler and GG through restart without retaining savestate ownership of CPU memory. SAVE-only does not enter this phase. Default-disabled restart ports preserve stand-alone T80s users until connected explicitly; the production system always enables the new LOAD protocol.
