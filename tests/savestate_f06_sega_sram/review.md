# F06 Sega SRAM ownership and snapshot architecture

**Decision E. HOST ASSISTANCE REQUIRED. Recommended next step 2: perform a focused host/cartridge-identity investigation.** F06 remains CONFIRMED — FIX REQUIRED. There is a proven 32 KiB snapshot solution for replaying the current machine, but no proven current-cartridge ownership contract. Those are different requirements. Do not implement a heuristic or an F06 format until the host boundary below is settled.

Investigation branch `investigate/savestate-f06-sega-sram`. Production RTL, v17 and the index are unchanged. No F06 implementation, Quartus invocation, resource optimization, format consolidation, FM investigation, commit, push or PR occurred.

The five requested prerequisite reports were read in full. Their SHA256s and all 204 tracked regular-file hashes are retained in [baseline.json](baseline.json). Prior optimization/consolidation prototypes are excluded. Source references below identify the current committed files, not historical line numbers from the original audit.

## 1. Current HEAD

`7fcd5e12847eedf9e97a44dc937c3dbac3205f7c`, committed F01. Branch creation is the only Git metadata change. [evidence.json](evidence.json) records the final source/build/report/log identities.

## 2. v17 confirmation

`rtl/savestates.sv`: `FM_MAGIC=24'h484311`, subtype 3; `NEW_SS_WORDS=24574`; 96 KiB container, DDR64 slot stride 0x3000. OPLL descriptor 2997 and payload 2998..29cb are unchanged. Test-created images have the actual v17 controller layout. No new format version is assigned.

## 3. Current resource/timing baseline

Retained exact-source F01 final build: Quartus 17.0.2 Build 602, Cyclone V 5CSEBA6U23I7, SMS/sys_top, seed 1, BUILD_DATE261025, original QSF/SDC/QIP/IP. The 137 manifest inputs are rechecked against this checkout; manifest's historical starting-HEAD field predates the F01 commit, so source hashes establish its applicability.

|Metric|Current production|
|---|---:|
|ALMs needed|37,175 / 41,910 (88.702%)|
|ALMs placed|38,598 / 41,910 (92.097%)|
|Fitted registers|48,948 / 167,640|
|Mapped registers|46,289|
|M10K|488 / 553; 65 free|
|Memory bits|3,818,050 / 5,662,720|
|DSP|39 / 112|
|Setup / hold|+0.105 / +0.206 ns|
|Failing timing-summary categories|0|

These are retained measurements, not new synthesis or a hardware signoff. Existing partially unconstrained paths remain a limitation.

## 4. Physical SRAM architecture

`SMS.sv:1782` instantiates **one 32768 x 8** `dpram`, shared by Sega SRAM, EEPROM backing storage, SC RAM, Castle and Dahjee/Codemasters expansion RAM. There is no separate Sega SRAM array or ownership store. Port A serves guest accesses and frozen savestate DMA. Port B serves persistent-file sector IO. `rtl/dpram.vhd` uses `altsyncram` BIDIR_DUAL_PORT, registered addresses, unregistered outputs, no clear/reset port, power_up_uninitialized FALSE. `rtl/nvram_ff.mif` initializes every byte to FF at FPGA configuration.

The array is 262,144 data bits already present in production. Capturing it does not require duplicating those bits in registers or a scratch M10K.

## 5. Bank organization

Two physical 16 KiB halves: bank 0 addresses 0000..3fff; bank 1 addresses 4000..7fff. Ordinary Sega addressing in `rtl/system.vhd:1063` is `(nvram_p and not A(14)) & A(13 downto 0)`.

At guest 8000..bfff, A14=0: `nvram_p` chooses either bank. At c000..ffff, A14=1: the address always selects physical bank 0, regardless of `nvram_p`. Thus extension visibility and bank selection are not interchangeable notions of physical capacity.

## 6. Visibility controls

`rtl/memory_bus.vhd:49–80`: `nvram_e` exposes 8000..bfff; `nvram_ex` exposes c000..ffff. `nvram_p` chooses the 8000..bfff half; `nvram_cme` exposes the Codemasters a000..bfff window. `ss_freeze` inhibits guest writes, not storage retention. Ordinary reads default to ROM/WRAM when the window is hidden. `mapper_eeprom` suppresses the ordinary write route and selects the EEPROM address/data source.

Guest FFFC bits 4/3/2 update `nvram_ex` / `nvram_e` / `nvram_p` in the ordinary Sega branch (`mapper_ctrl.vhd:412–425`). No bit records capacity, validity or ownership. In particular FFFC=00 hides both banks without erasing either; FFFC=04 is disabled visibility with bank-selection bit still set.

## 7. Mapper dependencies and complete interpretation inventory

`mapper_ctrl.vhd` priority is Janggun, EEPROM, blocked System E/SC/Castle/linear/Dahjee/Sega-locked cases, active 4PAK, Zemina, 4PAK detection, then ordinary Sega/Codemasters controls. Evolution has its own mapper restore semantics. Static ROM CRC/signature detection, manual mapper settings, bootloader transitions and restored detector history can therefore determine whether FFFC is interpreted as a Sega register.

Relevant state/configuration is: `nvram_e/ex/p/cme`; bank0..3 and mapper locks/Codemasters/4PAK state; detector flags/history and static ROM metadata; bootloader visibility; Janggun/Evolution selection; System E, GG and SC configuration; SC cart-RAM size; Castle and Dahjee selection; EEPROM selection and protocol address; freeze/preparation/refill/DMA address ownership. Persistent interpretation additionally uses `bk_ena/pending/state/loading`, old download/load/save/ack histories, queue bits, sector/buffer addresses, img_size/mount/read-only status. None is a per-cartridge SRAM owner.

`system.vhd:1531–1559` packs mapping flags into mapper word00f; bits50/51/52/53 are enable/extension/bank/CME, not SRAM profile. Bit61 also selects Castle transfer. IO's cart/BIOS visibility and OSD mapper settings are preconditions/restored controls, not certificates that hidden bytes cannot later matter. Runtime mapper redetection changes interpretation, not memory contents.

## 8. Reset lifetime

|Event|Bank 0 and bank 1|Controls/ownership|
|---|---|---|
|SMS soft-reset button|Retained|Guest port-DD reset input; game may subsequently write RAM|
|OSD/hard reset, RESET input|Retained|Mapper reset hides ordinary SRAM; no ownership change|
|BIOS configuration/reset, EEPROM soft reset|Retained except explicit EEPROM writes|Interpretation/protocol changes only|
|FPGA reconfiguration/power initialization|FF from MIF|Fresh physical instance, not retention|
|Mapper redetection/BIOS handoff|Retained|May hide/change decoding; no owner established|

`SMS.sv:436–452` clears **WRAM** through ram_clr_addr on reset. That machinery does not clear nvram_inst. `mapper_ctrl.vhd:125–149` clears mapping flags, not bytes. [lifecycle.log](lifecycle.log) tests RESET and status[0] retention at the start of both banks; actual mapper reset plus SAVE is separately exercised in witness I. Soft reset and FPGA configuration behavior are source proofs; no physical power-cycle test was performed. A host “core reset” that merely asserts RESET retains bytes; a core reload that reconfigures FPGA reapplies the MIF. These must not be conflated.

## 9. ROM-load lifetime

cart_download holds the guest in raw_reset. It replaces ROM and metadata and resets mapping/detection. It has **no write path clearing either SRAM bank**. Rising download clears bk_ena and bk_pending. Writable mounted-save notification may enable persistence; at falling download, nonzero img_size with bk_ena starts the persistent load. Without that transaction, both banks survive physically unchanged and initially inaccessible. There is no RTL ownership invalidation or relabeling event.

## 10. Same-ROM reload behavior

Without a persistent load, immediate same-ROM reload retains both old banks; mapper visibility resets. The first later enable reads retained data. With a persistent load, the file replaces bytes, potentially replacing newer unsaved RAM with an older file. [lifecycle.log](lifecycle.log) tests identical download streams, matching rolling signature, unchanged first byte in both banks, before a new guest SRAM access. A policy that clears every download would break this demonstrated retention behavior.

## 11. Different-ROM behavior

Different download bytes update ROM signatures but do not change SRAM. The lifecycle test changes the rolling ID, has no mounted file, then observes both old bank values. Later ordinary Sega FFFC writes expose them through the actual tested mapper/bus. Eject likewise disables bk_ena but retains storage. Physical stale contents are therefore already guest-observable in production; a snapshot does not create this contamination. Always restoring them does preserve it and can carry it to another session.

## 12. Persistent-save architecture

`SMS.sv:1759–1877` is the persistent SRAM path, distinct from savestate DDRAM. Port B address `{sd_lba[5:0],sd_buff_addr[8:0]}` covers **64 x 512 = 32768 bytes**, independent of current SRAM visibility/bank selection. sd_buff_wr & sd_ack writes the backing array; q_b supplies outgoing bytes. The FSM always visits sectors0..63. It tests img_size for nonzero, not a 16/32 KiB cartridge SRAM profile. Mounted writable media enables bk_ena; EEPROM can separately force it on. Neither establishes byte provenance or initialization completion for absent/short files.

Manual load is status6. Manual save is status7; autosave uses dirty bk_pending, OSD open and status25. Guest writes while OSD closed set pending if bk_ena; busy persistence clears pending. The menu hides backup operations without bk_ena, but the FSM's direct raw status-edge branch is not itself wholly gated by bk_ena; injected status commands are not an ownership proof. Full EEPROM/SC savestate restoration has special dirty hooks. Sega SRAM DMA restoration has **no corresponding unconditional dirty hook**. Do not assume a savestate LOAD is automatically persisted to disk. Visibility disabled does not invalidate file data, and persistent transport includes both banks even while hidden.

## 13. Persistent-load ordering

Automatic load starts after download completion if nonzero file size and bk_ena. bk_loading asserts raw_reset; RAM_clr_run prolongs reset for WRAM clearing afterward. This prevents ordinary guest execution during that load. The test fills all 32768 bytes through real sector/buffer strobes and checks terminal storage. The host response is simulated, not an actual MiSTer filesystem.

Savestate acceptance checks storage_busy=`bk_state | sd_ack | sd_rd | sd_wr`; persistence starts only while !ss_busy. A persistence request during SS is queued. Port B itself has no ss_freeze mask, so correctness relies on that protocol; unsolicited host writes during SS are not protected by the RAM mux. Queued explicit persistent LOAD can intentionally replace restored SRAM immediately afterward: the lifecycle regression demonstrates 99 from SS DMA, then44 from the queued file load. There is no automatic “reload file after every savestate” path.

## 14. Savestate transfer architecture

`savestates.sv:423–434`: 8 KiB if mapper48/53, 16 KiB if bit50, 32 KiB if bits51/52/61; Evolution excluded; SC/EEPROM use their independent extensions. `transfer_ram` uses SC size or those mapping predicates. A disabled ordinary Sega mapper with bits50..52 zero transfers nothing.

For ordinary SMS, existing NVRAM DDR64 base d01 and inclusive maximum1d00 already support 32 KiB. SAVE streams physical byte0 upward, not “active bank first.” Hence 16 KiB always means physical bank0. Eight bytes form each DDR64 word; two-clock RAM pipeline and the eighth-byte stall latch already exist. LOAD streams back at physical address0 upward.

Mapper restore precedes RAM transfer in ST_WAIT_RESTORE_BOUNDARY; guest remains frozen through SRAM, architectural state, CRAM, refill, flush and restart. CPU preparation has its existing address-ownership exception. No broad bank restore mux is necessary. System E instead uses the overlapping region for WRAM/VRAM; blindly adding SRAM there corrupts the layout. F06 should cover ordinary Sega-reachable storage, not indiscriminately transfer the physical array in every mutually exclusive mode.

## 15. Current ownership evidence

There is **no trustworthy SRAM owner/validity field in current production**. bk_ena means persistence available, bk_pending means dirty, nvram_e/ex/p mean mapping, detector history means observed mapper actions. None proves who populated each retained byte. A completed full file transfer can operationally replace the array, but no owner identity is latched with that completion. Both banks can contain guest writes from the current cartridge or stale previous contents with otherwise identical metadata.

For a clean ownership contract, “belongs to cartridge C” must mean: initialized/imported for C at an acknowledged lifecycle transition, or preserved from an already valid C-owned array; later guest writes retain that owner. It cannot mean “C eventually enabled a window.” Foreign retained bytes are not retrospectively C-owned merely because the physical core allows C to read them.

## 16. Cartridge identity evidence

There **is ROM identification information in RTL**; claiming none exists would be false. `SMS.sv:561–569` has 32-bit ss_game_id rolling signature, used in savestate header matching. `mapper_detect.vhd:96,505–519` computes full-ROM CRC32; CRC16 and header/opcode scans drive mapper quirks. `SMS.sv:660–672` cart_id is four header bytes used for Ys, not a unique ownership token. File extension/index gives type/loader index, not filename or unique cartridge identity. hps_io mount carries drive/read-only/size; no save-file owner ID, filename, generation or owner-completion token is delivered here.

Neither signature is associated with a retained SRAM owner, and neither is collision-free. [identity.json](identity.json) retains two distinct 32768-byte streams with identical ss_game_id=811c9dc5 and CRC32=703ab279. [identity.log](identity.log) reproduces both collisions using **actual mapper_detect RTL and the extracted production rolling-signature process**, not just a model. Changes are outside header metadata. This is a constructed byte-stream witness, not a named-game collision. Finite signatures remain useful ordinary ROM guards; their mere existence does not solve lifecycle ownership even when they differ.

## 17. Witness A — enabled at SAVE

Actual guest FFFC=08, banks31/72. v17 writes16384 bytes. After guest perturbation to a1/b2 and LOAD, bank0 reads31, bank1 readsb2. Current visible bank0 is exact; future bank switch is not. Controller case0 passes the expected-defect assertions.

## 18. Witness B — disabled after writing

FFFC=00 after writing both banks. v17 writes0 SRAM bytes. LOAD leaves a1/b2; later enable exposes both perturbed values instead of31/72. Case1 confirms the defect.

## 19. Witness C — bank0 selected, retained bank1

FFFC=08. 16 KiB bank0 restored, bank1 omitted and later visible. Case2 confirms. Selection and capacity must be separated.

## 20. Witness D — bank1 selected, retained bank0

FFFC=0c sets `nvram_p`. Current v17 therefore writes **32768 bytes** and restores both banks. Case3 passes both bank readbacks. The suspected “bank1 active omits bank0” class is **not reproduced in this ordinary Sega configuration**. Do not manufacture a symmetric bug; physical transfer always starts at0.

## 21. Witness E — 16 KiB transfer omits retained half

FFFC=08, case4: only bank0 transferred. Both physical banks remain reachable by later FFFC actions, so the current 16 KiB transfer is not proof of a 16 KiB physical cartridge profile. Defect confirmed.

## 22. Witness F — 32 KiB transfer

FFFC=18 sets extension plus enable. Case5 transfers32768 bytes and restores31/72. Both bank-selection and extension routes are source-traced; the dynamic probes use later 8000 bank reads. No missing-bank defect reproduced for this full transfer.

## 23. Witness G — before first SRAM access after load

Case6 tests disabled capture with retained RAM. The independent lifecycle test proves both same/different reloads retain those contents **before any new guest SRAM access**; mapper reset yields the same disabled capture condition used by cases8–10. This is compositional reachability, not a whole-top reload-to-CPU savestate simulation. No observed-access bit can recover the omitted RAM in this interval.

## 24. Witness H — after SRAM access

Case7 fills both banks using real decoded guest writes, selects bank0 and saves. Access occurred, yet only bank0 restores. An access heuristic would still need to preserve both full halves and distinguish ownership; it is not a valid substitute.

## 25. Witness I — reset then SAVE

Case8 writes both banks, asserts actual mapper RESET_n, releases, and saves while mapping is disabled. No bytes transferred; later guest bank reads expose perturbed SRAM. Lifecycle RESET/status tests establish the physical-retention side. No whole-CPU reset oracle is claimed.

## 26. Witness J — same-ROM reload then SAVE

Case9 covers mapper reset then disabled SAVE, paired with lifecycle same-stream reload before access. Both retained banks are omitted. The expected uninterrupted machine sees the old data; current LOAD sees the later perturbation. The old file may intentionally replace the data if an explicit persistent load occurs; these two lifecycle branches are distinguished.

## 27. Witness K — different-ROM stale data

Case10 covers reset/disabled capture; lifecycle different-stream download proves changed ID without changed SRAM or mounted file. A later mapper enable exposes old bytes. Current v17 is neither a complete snapshot nor an ownership solution. This is an actual production-path possibility, without claiming the normal host always omits a save-file mount.

## 28. Non-injective proof

The fixture writes both banks through the actual mapper/bus, varies only physical byte0 (41 versus42), then hides SRAM. Controller reset aligns the non-guest framework change counter before each SAVE; it does not clear SRAM. All 12288 DDR64 words begin identically, including unwritten holes. Both complete known **98304-byte** images compare byte-for-byte equal; [pair_a.bin](pair_a.bin) and [pair_b.bin](pair_b.bin) are retained with SHA256 in evidence.json. No header byte is masked in the comparison. The same future FFFC=08 then read8000 yields41 versus42.

This proves missing historical information cannot be reconstructed from a complete v17 image. Other subsystems are legal constant interface models; this is a production-controller/mapper/RAM composition, not a complete reachable T80/VDP execution proof. The SRAM histories and mapper writes themselves are real bus operations.

## 29. Required SRAM contents

With ordinary Sega capability unknown and both halves potentially retained, **32768 bytes are required**: independently mutable bank0 and bank1. Visibility does not reduce this. A genuinely enforced immutable profile could reduce payload to16384 or0, but no such profile currently exists. A 16 KiB profile must constrain all address/bank aliases before omission becomes safe. Under current semantics a bank-select write can expose the other half.

## 30. Required metadata

Mapping flags are already serialized. Full physical capture needs a new explicit presence/length/owner-mode descriptor so an unwritten pre-F06 slot area is never treated as valid data. A four-value profile requires2 bits; validity requires at least1 distinct status bit if not encoded jointly. Ownership needs either an authenticated host association or an explicit unowned/unknown status; a local finite generation alone cannot identify a portable cartridge. No trustworthy owner can be inferred retroactively for the running baseline.

## 31. Candidate A — always snapshot all physical Sega SRAM

Correct for exact replay of the existing ordinary-Sega machine, including SAVE before first access; requires no access history and uses existing sequential DMA. Same-ROM retention survives. Different-ROM stale bytes also survive and are restored, including after moving the savestate to a clean session. Later FFFC enables them; no mandatory persistence load intervenes. Thus A solves the image non-injectivity but **does not satisfy the requested exclusion of foreign stale ownership**. Profiles currently cannot prevent that visibility. An unconditional all-mode transfer additionally conflicts with System E storage layout and other owners of the shared array.

## 32. Candidate B — explicit current-cartridge validity

A validity bit is sufficient only if established by a defined full initialization/import/retain transaction before guest release. Inferring it from writes/accesses fails G. Setting it on every ROM load merely relabels stale contents. Clearing it on every load hides valid same-ROM retained data unless the backing contents are deterministically reestablished. Unknown validity cannot mean “skip RAM.” Conditional cost is small control state, but correctness still needs an ownership transition.

## 33. Candidate C — cartridge-generation ownership

A monotonically incremented load generation separates transactions, not cartridges. Tagging old RAM with an old generation detects that it is not freshly imported, but cannot decide same-ROM preserve versus different-ROM discard. Increment-on-every-load breaks same-ROM retention; keeping a generation on matching current finite signatures is a heuristic with concrete collisions. Generation wrap and portability require additional treatment. A generation is useful for canceling late persistence responses after ownership is independently established; it is not the identity solution.

## 34. Candidate D — host/persistence-derived ownership

A host that authoritatively associates ROM, persistence namespace and completed initialization can supply the missing transition. Current signals prove only mount attributes and the transport handshake. Mounted writable/no file/empty file/read-only/short file paths do not have an observed universal initialization contract. A full file load replaces both banks; disabled SRAM remains valid afterward. This candidate handles pre-access SAVE if initialization is complete before release. It needs focused host evidence, potentially a new identity/retain/new-owner/ready transaction; not assumed available now.

## 35. Candidate E — explicit SRAM profile/size

No exhaustive pre-execution Sega SRAM capability/size table or explicit host field is present. General mapper selection or ROM size does not determine physical SRAM. A database could provide a profile, but unknown/homebrew/modified images must remain UNKNOWN. Profile alone does not resolve stale contents, same-ROM retention or persistent-file ownership. A trusted 16 KiB profile would also need a defined bank alias/visibility contract; current unrestricted two-bank semantics cannot just omit a half.

## 36. Candidate F — hybrid

The viable conditional architecture combines authoritative ownership transition with conservative full32 KiB capture for UNKNOWN/ordinary Sega, existing mapping serialization, and sequential transport. Known smaller profiles may be supported only with enforced decoding and validated metadata. A new owner receives an agreed canonical initial array or its associated persistent image; same owner retains its valid array unless an explicit file-load operation replaces it. This requires a proven host contract first. It is a specification proposal, not tested production RTL or an implemented fix.

|Candidate|Before first access / same-ROM reload|Different ROM / stale bytes|Persistence / portability|Required core/host changes|
|---|---|---|---|---|
|A always32 KiB|Exact current replay / preserves retention|Faithfully preserves foreign stale data; fails isolation|Self-contained bytes, lacks owner guarantee|Core transfer/presence only; no host changes for weaker replay contract|
|B validity|Only if validity established at load / needs retain decision|A bit alone cannot establish provenance|Needs initialization completion and portable association|Core validity/init controls; host authority or new lifecycle policy|
|C generation|Pre-access tagging possible / reload increments need identity decision|Detects transaction age, not rightful owner|Generation not portable; file response tagging useful|Core counter/tags; additional host identity still needed|
|D host-derived|Yes after acknowledged ready / host decides preserve|Yes if new owner initialized before release|Associated file plus self-contained SS; portable owner key required|Host guarantee/metadata and core latch/ready/transfer; current guarantee unproven|
|E profile|Pre-access only if supplied / profile does not decide retain|Capacity cannot certify ownership|Unknown needs full data; portable profile insufficient alone|Core enforced decode/descriptor; authoritative host/database profile missing|
|F hybrid|Yes after ready / preserves proven same owner|Yes after explicit new-owner initialization|Ordered file import, full SS data and portable owner association|Host boundary plus small core controls and existing sequential DMA|

Only the conditional host-backed candidates meet both isolation and replay requirements; their FPGA planning costs are separated in section44. None has been implemented here.

## 37. Always-snapshot lifecycle proof

Concrete chain: cartridgeA writes31/72; cartridgeB downloads without persistent replacement; both halves remain; B saves while disabled; hypothetical full capture stores31/72; bytes later change; B LOAD restores31/72; FFFC=08/0c reveals A's data. No mapper profile currently blocks the reads and persistence does not automatically run on SS LOAD. Therefore unconditional capture faithfully records already-visible stale state; it does not establish B's ownership. Conversely skipping it breaks exact future replay. Both statements follow from the tested paths; neither justifies silently changing the lifecycle contract.

## 38. Unknown-profile semantics

UNKNOWN must conservatively retain both32 KiB halves for replay. UNKNOWN capability and UNKNOWN provenance are separate. Full capture plus explicit UNKNOWN can preserve an old running session exactly, but cannot certify it as free of foreign data. For a strict ownership guarantee, do not release a new cartridge until owner initialization is resolved. Host assistance or a new documented lifecycle policy is needed; silently choosing NO SRAM, clearing on first access or retroactive ownership relabeling is invalid.

## 39. Same-ROM proof and proposed contract

Observed: immediate same-ROM reload without file import retains RAM, even before access. Required proposed transition: if the host attests same owner and the current array is valid, preserve every byte and retain that owner; reset visibility only. An explicit persistent LOAD remains an intentional replacement. If current provenance is UNKNOWN, equality of ROM signatures alone does not repair it. A cold launch may instead initialize/import; this is not confused with warm same-owner reload.

## 40. Different-ROM proof and proposed contract

Observed: changed ROM signatures do not clear stale bytes. Required proposed transition: new owner invalidates the old binding, holds guest execution, initializes all future-readable bytes (canonical FF or associated file, with defined short-file fill), acknowledges completion, then exposes the cartridge. Full capture thereafter contains only the new owner's state. Late old-generation persistence responses must be drained/canceled. A different cartridge with no file must not inherit the previous array. These requirements cannot be certified from the present mount pulse alone.

## 41. Savestate-portability contract

An exact new-format F06 state must be **self-contained for SRAM**. Save S, then mutate SRAM and/or replace the persistent file: LOAD S must restore S's bytes, visibility and bank selection before the first guest read. It must not import today's file to reconstruct yesterday's omitted bank. Validate owner association against the loaded cartridge; reject a known mismatch before live mutation. Session-only generation is not a portable identity. Existing32-bit gameID remains an ordinary guard, not a new perfect-identity guarantee.

## 42. Persistence interaction

Proposed order: complete/drain cartridge initialization and any explicit earlier persistent load; accept and validate SS; validate owner/profile; hold guest; restore mapper and full SRAM through existing DMA; finish architectural restore/refill/restart; release. No automatic persistence read follows SS. Explicit subsequent user file-load may intentionally supersede it, as production already allows. Serialize such a request in a defined order or defer guest release until that operation completes; never allow concurrent port-B replacement during capture/restore.

A successful Sega SRAM SS LOAD should mark the persistence image dirty when backup is enabled, so later user/autosave can publish the restored timeline. This would be a focused implementation change, not done here. Do not write a foreign state's RAM into the currently mounted other cartridge's file.

## 43. Existing-transfer reuse

Existing15-bit addresses, 12-bit word counter, 64-bit pack buffer, 3-bit byte position, RAM read pipeline, DDR stalls and write port already cover32768 bytes. Correctness can use **the existing array directly while frozen**, not an OPLL-style scratch copy. Transfer4096 DDR64 words per direction. Compared with current omitted case: +32768 bytes; current16 KiB case:+16384; existing32 KiB case:+0. Sequential 8-bit writes avoid a 262144-bit parallel restore mux. No new M10K is intrinsically needed.

New owner initialization can also be a bounded sequential FF fill using the same memory port while reset/hold is asserted, about32768 memory-write clocks plus handoff, approximately0.61 ms at nominal clk_sys. This is an architectural timing estimate, not a measured implementation. No new SRAM clear engine was built.

## 44. Resource estimates for the models

These are structural planning estimates, **not fitted deltas**; no Quartus was run or necessary for this investigation. Small control changes can globally perturb placement and timing.

|Model|Added historical/control bits, excluding existing RAM|Planning logic/register scale|M10K|Transport|Main risk|
|---|---|---|---:|---|---|
|A full capture|presence/mode1–few bits|roughly10–100 ALMs,1–16 FF if existing DMA reused|0|32768+descriptor bytes|Ownership unsolved; mode exclusion|
|B validity|at least1 validity, transaction state|roughly20–150 ALMs,2–32 FF plus reused init counter|0|same full payload when valid/unknown|Unproven validity source|
|C generation|g-bit live generation and g-bit owner tag plusvalid|roughly20–200 ALMs,2g+1 FF; width-dependent|0|full payload plus generation metadata|Identity, wrap, portability|
|D host owner|identity widthI plusvalid/ready, handshakes|roughly50–300 ALMs,I+8–32 FF; host protocol unknown|0|full payload plus owner descriptor|Late responses, host guarantee|
|E profile|2 profile bits plus presence/validity|roughly20–150 ALMs,3–16 FF, excluding enforced decode|0|0/16384/32768+descriptor|Unknown profile and ownership|
|F hybrid|I+profile2+valid and transaction controls|roughly50–400 ALMs,I+16–64 FF|0|full unknown payload plus owner/profile record|Host contract and mode/restore control|

These broad ALM ranges are engineering envelopes for compare/decode/control, not evidence that any range will fit. No bits are added to the live data array. No large memory-data fanout is needed; address/control fanout remains local to the existing DMA/mux. A large parallel owner-ID compare is avoidable through a small sequential metadata check if host protocol permits it. I/g widths and exact state counts are not selected before the identity contract.

## 45. Format requirement beyond v17

Ordinary Sega needs **32768 payload bytes =4096 DDR64 words** independently of current enable/bank flags, plus explicit complete-payload presence and ownership/profile interpretation. Existing d01..1d00 fits in the current ordinary-SMS layout; no new32 KiB allocation or larger slot is inherently required. Reusing it requires a new presence/version rule, not reinterpreting unwritten v17 bytes.

A minimal replay-only descriptor could occupy one aligned8-byte word (presence/length/kind/reserved validation); mapping flags already exist. Profile costs2 semantic bits, validity at least1; owner identity costsI bits if used, optional generation g bits is not a substitute. A proposed record size is `8 + 8*ceil(I/64)` bytes including profile/validity in the descriptor; e.g.24 bytes for I=128. This is an alignment example, **not a selected identity width or assigned address/version**. Without owner ID, full replay payload+descriptor32776 bytes; with the example owner record32792. Relative new transport is that record plus0/16384/32768 depending on the former SRAM path. Full bytes do not overlap OPLL/sprite/BG. System E/EEPROM/SC mode ownership must remain explicit and separately validated.

## 46. Legacy fallback

Pre-F06 images cannot restore bytes never written. Safest compatibility policy is **reject an exact F06 LOAD when required SRAM completeness/owner association is absent**, without live mutation. If a separately explicit lossy-import mode is retained, keep historical footprint rules, label it lossy, and never read unwritten tail bytes or claim exactness. A deterministic canonical FF-fill of absent bytes could be specified for such an import, followed only by represented bytes, but it changes the existing legacy behavior and must be authorized/tested separately; it cannot recover the historical future. Loading today's persistent file is not an exact fallback. Public64's original Dahjee-only footprint must not be broadened into unwritten SRAM.

## 47. Host-boundary classification

**REQUIRES NEW HOST METADATA for a strict owner-aware guarantee under the currently proven interface.** At minimum a host-authoritative same-owner/new-owner transaction and acknowledged initialization/persistence association is required; equivalent existing host behavior may be sufficient only if the focused investigation proves it already supplies those guarantees. It is not presently proven. Do not assert “no ROM identity in RTL”; the missing element is trustworthy SRAM-owner association and lifecycle semantics. Replay-only full capture is RTL-ONLY, but that narrower contract fails the user's no-foreign-stale requirement. No impossibility of every conceivable RTL design is claimed: full retained-ROM comparison or a deliberately different reload policy are architectural changes, not evidence of a current trustworthy owner.

## 48. Selected architecture

Select the host-assisted ownership boundary, then conservatively reuse full32 KiB sequential SRAM capture while Sega capability is unknown. Keep contents, visibility, bank selection and ownership distinct. Reject unresolved ownership for a guarantee that excludes foreign data; permit an explicitly UNKNOWN legacy-session export only if its weaker provenance contract is authorized. Host must decide same-owner retain versus new-owner initialize/import before release. The FPGA must serialize completion, bind the owner, capture all relevant bytes and make SS LOAD authoritative over later file contents. No sticky sram_seen/cart_has_sram heuristic is part of this design.

This is the smallest **conditionally complete** architecture identified, not an implementation-ready resolved host protocol. F06 remains open until that prerequisite is met.

## 49. Capacity assessment

Existing free physical ALMs3312;65 M10Ks. Sequential reuse is plausible because counters, RAM ports and bulk transport already support32 KiB. No new data-storage M10K or hundreds of thousands of FF are justified. Metadata/control additions should be small compared with G06 parallel history, but +0.105 ns setup is too narrow to certify capacity from a source estimate. Routing and fanout changes can alter unrelated HDMI critical paths. An **early controlled Quartus gate is mandatory during implementation**, after ownership and functional witnesses pass; same source/config/date/seed baseline, needed/placed/FF/M10K/memory/DSP, timing, warnings and routing reported. No fit claim or resource optimization is made here.

## 50. Decision gate

**E. HOST ASSISTANCE REQUIRED.** A fixes disabled/both-bank/pre-access replay but fails ownership isolation. B/C/E alone have no proven authority to distinguish same-owner retained data from foreign stale data. A conditional host-assisted contract solves each listed class by establishing ownership before guest release and then capturing full unknown-capability RAM. Current production signals do not yet prove that contract. The host prerequisite is explicit rather than hidden behind a heuristic or an assumed file mount.

## 51. Recommended next step

**2. Perform a focused host/cartridge-identity investigation.** Inspect the exact MiSTer host version that drives this core: cartridge/save-path identity; same-file reload semantics; absent/empty/read-only/short-save behavior; sector fill beyond EOF; mounted-save timing; cancellation/completion; late responses; and whether a definitive retain/new-owner/initialization-ready indication already exists or must be added. Establish a testable identity contract for same ROM, distinct files/modified ROMs, cold launch and immediate reload. Then authorize F06 implementation separately. Do not start G08.FM or another optimization as part of that prerequisite.

## 52. Evidence, reproduction and limitations

[simulation.log](simulation.log):11 A–K component profiles, actual current controller SAVE/LOAD, actual mapper/bus and vendor dual-port RAM; expected omitted/full transfer counts and later bank reads; complete-image one-byte collision. All data mutations use real guest write decoding. [lifecycle.log](lifecycle.log): extracted production signature/persistence/dirty/RAM mux blocks, unchanged event logic, simulated host download and complete64-sector handshakes; reset/reload/eject retention, full persistent load, queued LOAD and persistent write count. [identity.log](identity.log): actual ROM metadata RTL plus production signature process validates a constructed collision for both32-bit signatures.

The accepted CPU/VDP/audio interfaces are constant legal component models; no actual T80 program or full SMS top-level host is simulated. A–K includes compositional load/reset reachability for G/J/K, explicitly identified above. Positive full-bank cases use representative byte readbacks and transfer counts, not an exhaustive randomized-address memory campaign. Additional lifecycle cases confirm that an empty writable mounted image retains stale RAM without auto-loading, and a read-only mount does not enable replacement. No malformed new-format, owner-protocol or proposed-model implementation test exists, because no fix was implemented. DDR is fixed-latency/ready here; shared randomized-stall machinery was not re-audited. No physical FPGA, game ROM, real persistent filesystem or host-source validation occurred. CRC collision is constructed, not a game/database diagnosis. Therefore selection E is a prerequisite decision, not CLOSED F06.

ModelSim10.5b needed three test-only `when others => null` additions to binary-address case statements in a copy of mapper_ctrl; valid binary behavior is unchanged. Controller adapter moves two forward declarations and adds the existing TB_FAST parameter to skip the900000-clock presentation flush; acceptance, SRAM count/address/data and DDR FSM are unchanged. UI cooldown is bypassed. No payload field is masked, and the floating inherited restart input is tied to0. Other omitted ports are unused outputs. Arithmetic warnings while unselected RAM addresses are unknown during freeze are suppressed as in prior fixtures; every stored image word is asserted known. Native compiler/elaboration pilots and one initial unequal change-counter pair are excluded; controller reset now aligns counters without masking any image byte. All final three logs require explicit PASS and zero errors; shell exit code alone is insufficient with this simulator's $finish handling.

Reproduce from repository root:

```powershell
node tests/savestate_f06_sega_sram/prepare_all.js
node tests/savestate_f06_sega_sram/identity.js
node tests/savestate_f06_sega_sram/identity_rtl.js
Set-Location tests/savestate_f06_sega_sram
& C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe -c -do 'do run.do' -l simulation.log
& C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe -c -do 'do lifecycle.do' -l lifecycle.log
& C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe -c -do 'do identity.do' -l identity.log
Set-Location ../..
node tests/savestate_f06_sega_sram/verify.js
```

Preparation recreates only investigation fixtures and its baseline manifest. Existing tests elsewhere are preserved. No changes to production are made by these scripts.

## 53. git diff --stat

```text
(empty)
```

All tracked-file hashes and the137 retained build inputs match. No generated Quartus files were created or tracked. New fixtures/reports/logs/images are isolated under this pre-existing untracked tests tree. Nothing staged.

## 54. git status --short

```text
?? tests/
```

HEAD unchanged; production v17 unchanged; no F06 fix or G08.FM change; no commit, push or PR.
