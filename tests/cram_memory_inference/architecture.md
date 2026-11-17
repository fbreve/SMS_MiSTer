# CRAM inventory, contract and option selection

Baseline v19,1b2a52d. Source identifiers below refer to the preserved baseline
under baseline/ and unchanged surrounding production VDP logic.

## Storage and access

Two independent palettes, one per VDP:32 entries×12bits=384bits each. System E
uses both; ordinary SMS/GG rendering uses the primary. CPU/restore writes share
one rising-edge process with strict restore priority. Renderer reads are one
registered rising-edge lookup. The entity exposes two clock inputs, but both
are connected to clk_sys in production. No asynchronous runtime reset exists;
all32 words initialize to FFF. Warm VDP reset does not clear palette contents.

The baseline exposes every entry combinationally through384-bit ss_D. ARM
captures that vector into the existing controller384-bit scratch. Six64-bit
DDRAM words serialize each palette at8..d and12..17. LOAD fills those scratch
records and writes each of32 palette entries using existing ss_wr/A/D. The
snapshot and live RAM are different lifetimes, not interchangeable copies.

SMS writes replicate each two-bit channel into four bits. GG uses an even-byte
low latch and commits a12-bit word on the odd byte, with address shifted by one.
These conversions are upstream in vdp.vhd and are unchanged. Legacy TMS modes
use the existing fixed-color decode; inactive palette history still remains.
System E owns separate palettes and strobes. All12 bits must survive restore.

## Measured baseline inference

The v19 Fitter attributes364.3 primary/366.8 secondary exclusive ALMs and399/404
FF to the CRAM entities. Neither has a RAM-summary instance or M10K allocation.
The whole design has no ALMs classified as inferred memory: these arrays are
ordinary FF plus mux/decode logic, not a hidden MLAB RAM. Synthesis/Fitter
hierarchy and full RAM tables are retained in the structural resource audit.

## Barrier classification

- Full32-entry parallel snapshot read: savestate-only, incompatible with an
  ordinary one-/two-port block RAM. Main barrier, not renderer timing.
- Prioritized CPU/restore writes: one effective write port, not intrinsically
  incompatible independent writers. Restore selection adds address/data muxes.
- Renderer: synchronous registered read, intrinsically required one-clock
  behavior. Additional latency is visible and forbidden.
- Snapshot output: asynchronous and wide; serializing it is private frozen
  transport and can add bounded host clocks without adding guest clocks.
- No runtime async array reset. Initialization-to-ones must remain.
- No CRAM byte enables internally: frontend converts SMS/GG writes to full12-bit
  commits. Do not change that frontend or GG latch semantics.
- Same-address CPU/restore write and renderer read: renderer receives OLD data
  on the edge, NEW on later reads. Must not use don't-care mixed-port semantics.
- Same clock in production: no new CDC. Different-clock testbench operation is
  outside the production configuration and cannot justify changing the clocks.

## Selected single architecture

Use RAM port A for the normal prioritized write or the private synchronous
snapshot read; use port B for the unchanged renderer read. During scanning,
ss_rd chooses ss_A and no guest writer is permitted. Read Q on A is only
consumed after a nonwrite read; its value during writes is not a contract.
The HDL holds it on writes, avoiding an unnecessary same-port RDW requirement.
Port B still must preserve old-data mixed-port behavior on every guest/restore
write. The existing production VRAM already uses same-clock OLD_DATA dual-port
memory; actual CRAM inference remains a required build check, not assumed.

ARM starts address0. One wait edge lets the registered read complete; the next
edge collects it into the existing scratch ring using12-bit insertion. Repeat
for addresses0..31. After32 insertions the first entry occupies bits11:0 and
last occupies383:372, exactly the old parallel snapshot. Both VDPs scan in
parallel. This adds64 private clocks before the existing DDR drain; neither
renderer timing, LOAD sequence nor G10 release changes. No new staging bank.

Acceptance boundary quiescence is essential. A CPU write is registered into
data_write, then commits to CRAM on the next host edge. A pending ARM-edge write
would make a later scan differ from the old pre-edge snapshot. The accepted M1
memory-read CPU bus excludes an I/O/memory write; native CPU write phases last
longer than the /5 VDP sampling plus one host-edge completion. Evolution edge
capture reacts to falling write edges, not the rising end of the old write.
The original G03 boundary counter and new explicit ARM/scan monitors test this
producer argument. No blanket freeze assumption or write-suppression change
was made. A detected write during scanner ownership is a test failure.

## Options A–F

|Option|Inference / expected structural effect|Cost, latency and risks|Disposition|
|---|---|---|---|
|A sequential snapshot access|Removes parallel taps; enables ordinary addressed RAM; does not alone specify storage primitive|Private scan control/read register; renderer must stay one clock|Required part of selected architecture|
|B separate staging RAM|Does not by itself remove live palette parallel exposure/FF|Adds memory/transfer ports; current LOAD already has suitable small staging|Not selected|
|C dual-port inferred RAM|Replace768 live array FF with two32×12 M10Ks; actual mapped reduction unmeasured before build|+2 blocks expected; read-address/write muxes and12-bit Q per owner; OLD_DATA required|Selected with A and D as one access/storage change|
|D reorganize ports|Share CPU/restore/snapshot ownership of A, retain renderer B|No guest-cycle change, no third port or CDC; scanner/write exclusion must be proved|Necessary implementation of C, not a separate redesign|
|E remove redundant snapshots|Controller scratch also holds validated LOAD data; no redundant semantic bank proven|Removing it would couple LOAD validation/application; no forecasted saving|Not selected|
|F alternative restore sequence|Current entry writes already suit one RAM port|Changing order/early guest writes adds proof surface without solving parallel capture|Keep existing restore sequence|

Expected FF reduction is a source-level live-array target, not an ALM forecast.
Two M10Ks are acceptable only if actual placed resources and timing improve.
This differs from the rejected G06 sequential conversion: naturally addressed
palette entries already have a renderer RAM read and word write; no crossing
74-bit slot fields, multi-owner reduction tree or per-bit scatter is added.

## Proof composition and observations

1. The component miter compares exact initialized contents, priority writes,
   every renderer response and synchronous scan reads to renamed committed
   CRAM across all32 addresses and randomized same/adjacent operations.
2. Symbolic insertion after32 reads equals the old384-bit packed image.
3. Paired controllers export all12,288 words for16 phase/owner/consumed-T
   protocol profiles and three LOADs each with randomized full palettes.
4. Actual T80/VDP regressions check scans against actual ARM RAM contents,
   CPU-write exclusion, original first-output/color/status/CPU/RAM oracles,
   mode transitions, dual owners, transport stalls and long suffixes.
5. Format/import tests retain padding/tag rejection and legacy semantics.
6. Full synthesis/fit must show actual block inference, no extra renderer
   pipeline, resource savings, routing and timing qualification.

Native fixtures expose full RAM only through simulation-only combinational
observation taps in copied sources. Production has no such tap. They observe
actual candidate RAM, not a scoreboard substituted for memory. These extra
ports/assignments have no state or effect on renderer/write/scan transitions;
the exact production source and instrumentation bridges are hash-recorded.

Compatibility refinement: old64 System E bypasses the second palette payload but still restores its ARM-captured live value. Therefore early scanning runs on SAVE and System E LOAD. Non-System-E LOAD still skips the scan; all LOAD palette installation/validation remains unchanged. This preserves the existing fallback rather than creating a new default. Both paths require capture-edge quiescence.

Measured synthesis refinement: the selected generic array maps to two simple
dual-port replicas per palette, not the initially expected single true dual-port
block. There are four 32x12 M10K instances and1536 physical logical bits for768
guest palette bits. All four have common CLOCK0 address registration, OLD_DATA
mixed-port behavior and FFF initialization. This is a physical replication of
one historical state, not new saved state. The fit/decision must use the actual
four-block cost; the original two-block forecast is not a measured result.
