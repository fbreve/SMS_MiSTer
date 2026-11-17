# Pre-production structural hypothesis and proof plan

Baseline1b2a52d/v19. No production changes at this point.

CRAM is32×12 initialized to all ones, no runtime reset. Restore and CPU writes
are mutually prioritized in one clocked write process. Renderer reads are
registered, with old-data same-address read/write semantics. Both physical
clock ports map to clk_sys. Full384-bit asynchronous snapshot exposure is the
established additional read-port barrier; the Fitter allocates no M10K to
either palette and approximately731.1 exclusive module ALMs combined.

Candidate: keep renderer latency and write priority; use the write-side RAM
port for a synchronous12-bit snapshot read while guest writes are quiescent.
Scan32 entries into the existing384-bit controller staging bank per VDP.
Retain full LOAD staging, palette addresses/words, restore writes, v19 format,
sprite rings, CPU/G10 reconstruction, beam/phase/mixer release and all other
history. Expected trade: replace768 live FF with two small M10Ks, add read
registers and bounded scan control. ALM saving unknown until full fit.

Before production edits:

1. Compare isolated candidate to renamed committed CRAM for init, all32
   addresses, exact renderer every-clock old-data response, same/adjacent
   address writes, priority restore, random12-bit data and repeated scan/load.
2. Establish capture-edge quiescence at accepted M1 boundaries using producer
   timing and real CPU/VDP tests. data_write is a one-host-clock pulse, but
   normal writes are registered one edge before the RAM commit: a pending
   ARM-edge write would invalidate a delayed snapshot. Do not assume it absent.
3. Keep both palette read/write clocks on clk_sys. No extra renderer cycle,
   unsafe CDC or write exclusion outside snapshot ownership.
4. Prove scanner issue/collect ordering and full384-bit capture equivalence,
   all image words, legacy/current imports, System E and stalled repeated LOAD.
5. Run affected actual-VDP G02-G06/G10/G05 mode/render/native regressions and
   long/random coherent suffixes against committed v19. Do not infer first-pixel
   correctness from a settled RAM dump.
6. Only after simulations pass, one source-controlled full Quartus build with
   baseline settings/date/seed. Inspect actual inference, needed/placed/FF/RAM,
   warnings, route and all-domain timing. Keep only measurable placed gain,
   passing timing and no new critical warnings; otherwise restore production.

The register/renderer proof and legal capture quiescence are the safety gate,
not completed proof claims. No G06/G10 storage or format consolidation allowed.

Compatibility refinement: old64 System E bypasses the second palette payload but still restores its ARM-captured live value. Therefore early scanning runs on SAVE and System E LOAD. Non-System-E LOAD still skips the scan; all LOAD palette installation/validation remains unchanged. This preserves the existing fallback rather than creating a new default. Both paths require capture-edge quiescence.
