# G12 live SDRAM investigation

**G12: CONFIRMED - FIX REQUIRED.**

**Shared memory-transfer proof: CLOSED - PROVEN.**

Production RTL and v16 are unchanged. No fix or Quartus was authorized or performed.

1. **Committed HEAD:** 08cf1426bfd2e1f2a73fdb25aaf57715d408db11, branch investigate/savestate-g12-sdram. The user committed the prior v16 fix before this investigation. [baseline.json](baseline.json) retains raw hashes for all 203 tracked regular files.

2. **v16 baseline:** Current production MIXER_MAGIC=484310, unchanged container96KiB and all inherited records. No format or production transition was edited. The five requested historical reports were read completely; results.json records their hashes and distinguishes their historical versions from current source.

3. **Memory architecture:** [architecture.md](architecture.md) maps current requester/address/strobe/data/ready/buffering/ownership and first consumer for cartridge ROM, BIOSes, WRAM, cart/SC RAM, EEPROM, both System E VDPs, screen-rotation DDRAM and savestate DDRAM. Actual modules are rtl/sdram.sv; rtl/memory_bus.vhd; rtl/memory_decode.vhd; rtl/evolution_rom_address.vhd; spram/sprom/dpram; and sys/sysmem.sv module sysmem_lite with f2sdram_safe_terminator and HPS hard interfaces. File/module names were checked in current source.

4. **Exact G12 scope:** The single live SDRAM ROM controller between CPU rom_RD/raddr and physical SDRAM pins, ending at SMS ram_dout/system rom_do8. It is separate from savestate DDRAM and architectural on-chip RAM. CPU ROM requests are the sole guest requester; download writes belong to an immutable-media/reset session prerequisite.

5. **Sequential inventory:** [state_inventory.md](state_inventory.md) inventories q4, a23, bank2, data8, sd_dat16, wr1, ram_req1, old_ref1, old_rd1, mode2, initialization counter5/init_old1, rd_rdy1/we_ack1 and all registered command/address/bank/DQ outputs, with assignment/reset/consumer/freeze/SAVE/LOAD details. It separately lists direct download-wrapper and DDRAM platform/reset/terminator state. No burst/cache/open-row table or independent refresh timer exists in the live controller.

6. **State classifications:** No live controller field is serialized. Initialization/download state is BOUNDARY-EXCLUDED; normal reads complete before accepted consuming T2. Cache-history tests support ordinary overwrite-before-consumer behavior. The final witness overrides any universal reconstruction claim: q/clkref alignment and retained a/bank/sd_dat/byte lane are POTENTIALLY FUTURE-RELEVANT because the restored request can miss acceptance entirely. old_rd is correctly low; stale ready=1 is not evidence of a current completed read.

7. **Accepted SAVE:** Production ST_WAIT_BOUNDARY requires !storage_busy && cpu_ce && !M1_n && !MREQ_n && ISet00 && VBlank && x<256. Running fetch T2 consumes at accepted T; CPU architecture/context capture is pre-T, devices are post-T at ARM. Actual ss_freeze holds T+1. Suppressed paused-T capture is also legal and records capture_tick=0. Request time is not acceptance time. Trace logs retain CPU/bus, q/request/ready/data, freeze, controller and DDRAM signals.

8. **Freeze/drain:** Live SDRAM is never explicitly frozen or drained by ss_freeze. The32-consecutive-idle-clock drain observes only DDRAM_BUSY and DDRAM_DOUT_READY after ownership switches from screen_rotate. Raw clkref continues; physical responses/refresh can advance. Flush/settlement alone does not prove that restored T1 has been accepted. The900,000-clock production flush does not fix the confirmed failure.

9. **Deterministic model:** pin_model.sv decodes physical ACT/READ/refresh, bank/row/column and both byte lanes with fixed CAS2/single-word mode. Nonuniform deterministic address hashes define immutable bytes; real program bytes occupy the boot/code window (System E fixed physical40000). TAC0/3/7ns under20ns host-clock simulation vary legal data arrival within the fixed capture window. CPU reset is held until natural SDRAM initialization finishes; no q/mode/address/data register is deposited. Ordinary-read and returned-address/data assertions reject unknown/wrong consumed values. Inactive uninitialized write-only payload/pin drive is not an X-equality oracle.

10. **Request before SAVE:** 36 real-CPU offset cases across normal /15, turbo /10 and System E /10 pass SAVE-only and LOAD. Programs issue nonsequential and adjacent ROM reads around3FFF/4000 and7FFF/8000, write signatures and change actual mapper banks. Each case compares full CPU230, address/strobes, six signature bytes, PSG/divider and stereo on every logical host clock from k0.

11. **Accepted request/pending response:** For ordinary aligned fetches, q0 acceptance follows T1 and q6 returns within7 host clocks, before next10/15-clock consuming T2. Accepted running SAVE cannot stop within that pending interval. Component tests sweep every request-issue phase. The confirmed LOAD is different: its restored read is generated but never accepted before first consumption, not an accepted request whose response was dropped. Transaction flight=0 at the bad fetch is explicit evidence.

12. **Returned but not consumed:** Naturally present before consuming T2 and in a paused M1/T2 capture. Paused capture/read/LOAD while still paused passes. Loading the same suppressed-T image while host UI is running fails for one legal private-clock alignment. Thus returned data at T is insufficient to justify the first restored consumer after arbitrary Q.

13. **CPU consumed:** Running captures take the post-T bus transition while saving pre-T2 CPU architecture/context; historical T1/T2 reconstructs it. All positive running cases match exactly, including full-flush and repeated LOAD. The new suppressed-T case needs only private T1; its later first running T2 consumes stale opcode32 instead of23.

14. **Exactly once:** Positive transaction scoreboards require one physical READ and matching returned byte/address per acceptance, no overlapping/unowned/duplicate return, and accepted=returned+one permitted final in-flight request. All2625 component reads are exact. The witness violates the request/consumer contract: T1 read is lost before q0 samples it, yet CPU consumes the retained word. Re-fetch during LOAD preparation is intentionally an immutable-ROM reconstruction transaction, not a duplicate guest write/effect.

15. **Minimum latency:** TAC0 fixed-CAS2 component setting passes /10 and /15 phases; real CPU TAC0 passes SAVE and three LOADs. No variable CAS/WAIT protocol is invented.

16. **Middle latency:** TAC3 component and real CPU cases pass, with distinctive bytes and repeated LOAD.

17. **Maximum modeled latency:** TAC7 is the largest supported arrival delay tested within the10ns half-clock window, and passes component and real CPU cases. A read delayed beyond the controller sampling deadline is not legal backpressure for this interface and would break ordinary execution.

18. **Backpressure:** Live SDRAM has no backpressure input; rd_rdy is an unconnected output and WAIT defaults1. Legal variation therefore covers data-arrival timing and natural request/clock phases. DDRAM separately uses read latencies1/3/29 and legal busy profiles13/31, seeded12/16 and2020/2048. Final-response tail delay0 versus8 is the causal LOAD transport control.

19. **SAVE-only:** All65 positive integration cases compare uninterrupted reference versus SAVE-only before replays; no divergence. The confirmed defect is specifically paused-image LOAD into current running UI with unsafe private-T1 alignment. It is not inferred from a reset/idle register alone.

20. **Transport duration:** Ordinary and System E positive read/transfer cases survive broad stalls, including the production full-flush representative. Universal independence is disproven: add8 legal host clocks to the last actual System E DDRAM read response (offset2900) and the same image changes from safe private T1 at phase10 to bad private T1 at phase25. No internal divider state is forced.

21. **Repeated LOAD:** 79 positive LOADs use immutable complete saved images after varied running Q/mapper/ROM/PSG histories. The isolated failing paused-to-running witness was reproduced with shortened and production flush; it is not counted as three repeated failing LOADs. The stop rule precludes a broader post-confirmation failure matrix.

22. **Non-injective search:** Two natural cache-history pairs have equal complete known v16 images but different retained address/word:0040fd/47f5 versus0041fd/454b. CPU/WRAM history is canonicalized by guest execution, not register deposits; RAM-resident code avoids further ROM reads until an identical future NMI exercises ROM again. Both futures/repeated LOADs match. Strict pair SHA256 be1e50ac1381873d388e93dffe6cf502e1c229d9958270ec553dc9d461dcbcda. Separately, safe/bad LOAD histories use the same image 29aa0d28179b8b3ab186709f7ffa65295a3a8c41f94076f91337209c3ad912ba. This is a transport/reconstruction-order counterexample, not proof that different accepted SAVE histories require new payload.

23. **Arbitration:** No multiple guest requesters exist. Neither VDP nor guest RAM/EEPROM uses live ROM SDRAM. q0 host-download write priority is real, but download holds reset and changes immutable session media; overlapping SAVE is excluded. No phantom A/B guest arbitration cases are invented.

24. **Addresses/banks:** Production mapper_ctrl plus memory_decode are instantiated. Guest writes FFFE/FFFF, reads across page/bank edges and stores distinctive bytes. System E uses its actual fixed/banked address decode at ROM bank0/5/10/15. Standalone requests test low/high addresses, both byte lanes and each of25 one-hot address bits; bit24/full32MiB is component capacity coverage, not claimed reachable through the current24-bit top-level ROM bus.

25. **System E:** Normal System E running and still-paused positive cases pass; independent VDP contexts use private BRAM and do not arbitrate live SDRAM. The confirmed path is the supported paused-save/current-running-load transition. Existing host Pause semantics are preserved; this finding does not propose loading historical host UI Pause.

26. **Refresh/background:** Unused slots auto-refresh; q is resynchronized by raw clkref, not serialized. Component offset/delay cases and natural cache-history pairs tolerate different background history. Refresh state alone is not implicated: the bad path consumes before request acceptance, and ready remains from an older request. No physical refresh-phase payload is recommended.

27. **v16 restart interaction:** Failure trace, production flush: private T1 at cycle3578155, raw phase25, pixelCE0, q4. Restored PC003F requests physical04003F. Release3578157 sees q7, old_rd0, old address04003C, data32. At first running T2 cycle3578167, q15/ready1/flight0, CPU consumes32 instead of23; q0 only follows after T2 has deasserted rd, so the request disappears. First architectural difference3578177: actual HL3FFD versus golden3FFE. Safe tail0 T1 occurs at phase10, accepts at q0 and completes before consumption. This disproves the unconditional reconstruction assumption without reopening the deterministic G10 phase/CPU contract itself.

28. **G12/G11 boundary:** The mismatch is on raw rom_do before any decryption. The independent golden T80 receives identical restore/enables, production mapper/address decode, RAM and immutable bytes directly, bypassing only SDRAM timing. Full-flush golden/live CPUs match244,429 pre-LOAD comparisons before the fault. MC8123/SEGASYS1 registered history remains G11; no decryption proof or fix was attempted.

29. **Ordinary WRAM:** 8KiB prefix data, all byte-write counts, first/last/eighth boundaries and inactive upper8KiB canaries pass. Command fixture separately checks exact1024 payload words at offset901 and saved image bytes.

30. **System E WRAM:** 16KiB data and every destination byte exactly once pass; command fixture checks2048 words at901. Strict data distinguishes the two8KiB portions; the earlier simpler pattern matrix is not used alone to infer high-address correctness.

31. **Four physical System E halves:** Both32KiB VDP memories are initialized distinctly. Active/passive16KiB halves route through offsets101/1901 and1101/2101; each of65536 bytes is restored exactly once with no cross-port writes. Shared-transfer proof uses production-equivalent synchronous memory endpoints, not a repeat of renderer/sprite state proof.

32. **Independent bank selections:** All four combinations of mapper bits7/6 are exercised, including opposite active selections and distinct ROM banks. Expected physical data and per-address counts check every half, not only selected CPU-visible banks.

33. **Random patterns:** Strict seeded address-hash patterns provide nonuniform deterministic pseudorandom bytes with different high-address/owner content, in WRAM and both VDP memories. They are initialized once and independently scored.

34. **Address patterns:** Strict folded address/owner pattern preserves high-bit distinctions; separate real CPU reads use a different nonuniform immutable ROM hash.

35. **Boundary canaries:** WRAM0/7/8/8191/8192/16383 and complete inactive tail are checked, with expected guest bank-write effects captured at SAVE. Full per-byte VRAM expectations include each half boundary.

36. **Exact lengths:** Ordinary8192 WRAM/16384 VRAM bytes; System E16384 WRAM/32768 VDP1/32768 VDP2. Destination write counters reject missing, duplicate or out-of-range writes; full image byte checks are independent.

37. **Transfer delayed ready/stalls:** Read latency1/3/29 and deterministic/LFSR/long stalls pass. The independent System E command case uses the heavy2020/2048 profile and latency29. It is kept separate from the G12 source-memory contract.

38. **Duplicate/missing commands:** Command observers require one accepted DDR command per payload word on SAVE and LOAD, burst1/full byte-enable for memory payload, and exact image bytes. Architectural metadata legitimately includes PSG2 byte-enable7F and header partial writes; an overbroad initial observer assertion was corrected to restrict the full-mask rule to RAM payload, with its failed pilot retained. No payload equality/count assertion was weakened.

39. **Shared transfer classification:** CLOSED - PROVEN, for the requested WRAM/four-half/bank/pattern/ready/count cases under the legal DDRAM user interface and no platform reset. It does not prove HPS/Linux hardware, reset termination, F06 Sega SRAM, or the independent G12 first-fetch ordering.

40. **G10 sanity:** Positive cases compare raw clkd and first logical CPU/PSG/audio transitions; private preparation asserts PSG hold and48-clock bound. G10 remains CLOSED. The memory path assumed by private T1 is what fails, not deterministic divider phase installation.

41. **G08 sanity:** Real primary/secondary JT89, phase handoff and first stereo/raw suffix compare in the positive cases. A directed accepted phase10/pre-divider14 pending-tick case passes SAVE/LOAD. G08.release remains CLOSED; G08.FM remains OPEN - BLOCKED BY F01.

42. **G01 sanity:** Real T80 executes bank writes, reads/stores, RAM-resident code, NMI/RETN and historical restart. Full architecture/address/strobes and signature compare from k0 in positive cases. Golden replay shows correct private CPU semantics when data is correct; G01 stays CLOSED. No exhaustive instruction matrix was rerun.

43. **Simulation accounting:** 65 positive integration parameter cases,79 LOADs,924,000 exact logical host-clock comparisons. Six component settings cover2625 transactions. Two canonical full-flush characterizations (safe control and confirmed fault), 138 completed runtime invocations including references. Shortened-flush fault/control and setup pilots are supporting evidence, not extra canonical passes. [results.json](results.json) contains the exact log/hash ledger.

44. **Guest-visible divergences:** One distinct G12 defect, two retained fault reproductions (fast and production flush). Each produces one wrong first fetch and98 architectural differences over the bounded1000-host-clock characterization. Safe full-flush control produces zero. No new G11/FM/F06 defect is asserted.

45. **Complete-v16 equal images:** Two benign natural accepted-cache pairs differ in omitted live address/data but have equal full images and futures. The safe/bad restart pair also has byte-identical full images, but differs in legal pre-release DDRAM latency history. No naturally different accepted-SAVE pair with divergent future under an identical complete subsequent restore schedule was established; a format-injectivity defect is not the required diagnosis here.

46. **G12 final classification:** CONFIRMED - FIX REQUIRED. The protocol can consume a restored fetch before live SDRAM has accepted it. A universal boundary exclusion/reconstructability closure is false.

47. **Limitations/stop rule:** After confirmation, no production fix/prototype or Quartus was attempted; only bounded full-flush/control characterization and already-independent transfers finished. No physical FPGA/game-ROM campaign, encrypted input proof, arbitrary chip violation/backpressure, global reset during DMA, or exhaustive paused/normal clock cross product is claimed. Decoder/address/CPU adapters, fixture scope and failed pilots are documented in README.md.

48. **Production/v16 unchanged:** All 203 tracked regular-file raw hashes and HEAD match baseline; tracked/staged diffs empty. Live SDRAM simulation adapter only separates the procedural DQ driver from the resolved wire and names its block for observation. Current transitions are mechanically verified. No production RTL, format, Quartus, staging, commit, push or PR.

49. **git diff --stat:** 

```text
(empty)
```

50. **git status --short:** 

```text
?? tests/
```

Historical untracked tests/ existed before this task; new work is confined to tests/savestate_g12_sdram. Simulator caches/reference streams are ignored.

51. **Exact next task:** Authorize a minimal G12 fetch-acceptance/completion restart fix before G11. Establish a current-request completion contract for one-private-T1/suppressed-T LOAD with current UI running, then prototype and prove before production edits. Consider coupling private read setup to the live SDRAM clock/reference or fencing release until that specific request is accepted/completed; simply waiting for rd_rdy=1 is insufficient because it is already stale-high. No evidence requires serializing historical q/a/sd_dat or changing v16. Preserve both full-flush control/fault, same-image transport pair, normal/turbo/System E, Pause, repeated LOAD, pending PSG and shared-transfer regressions. G11 should remain deferred until G12 is fixed.
