# Sega SRAM ownership architecture investigation

Investigation only, at `b0f4b71` on `fix/savestate-cart-ram`. No production RTL changes. This review supersedes the abbreviated `cart_ram_stop.md` investigation; it does not implement F05 or F06.

**Decision:** recommend a hybrid, typed cartridge memory profile with an explicit **unknown** capability value. Reject persistence flags and a sticky-use bit as the sole savestate inclusion predicate. F05 can be separated. F06 remains blocked on the treatment of unknown cartridges: existing RTL cannot establish physical cartridge SRAM ownership before first use. A conservative reachable-backing policy can make emulated snapshots complete, but it is a different contract from proving a cartridge possesses SRAM. Do not silently turn that policy into `cart_has_sram`.

## 1. Current dataflow and physical topology

```text
Host ROM bytes/index/extension + OSD mapper selection
  SMS.sv:452, 535, 732, 782, 950, 1115
          |
          v
mapper_detect: CRCs/signatures/size + runtime write heuristics
  rtl/mapper_detect.vhd:168, 241, 270, 379, 415, 521, 571
          |
          v
mapper_ctrl: selected register map, guest $FFFC bits 4/3/2
  rtl/mapper_ctrl.vhd:317, 354, 391, 402
          |
          +--> nvram_e / nvram_ex / nvram_p / nvram_cme
          |    (visibility/banking, not retained ownership)
          v
memory_bus: CPU read mux + write qualification
  rtl/memory_bus.vhd:39, 48, 58
system: physical address and EEPROM data/write mux
  rtl/system.vhd:1000, 1011
          |
          v
SMS.nvram_inst: 32768 x 8 FPGA dual-port RAM
  SMS.sv:1680; rtl/dpram.vhd:91; rtl/nvram_ff.mif:1
  A: CPU normally, savestate DMA under ss_freeze
  B: {sd_lba[5:0], sd_buff_addr[8:0]}, write sd_buff_wr & sd_ack
          |
          v
host persistence: mount eligibility, dirty flag, 64-sector controller
  SMS.sv:1660-1773; sys/hps_io.sv:128, 461
```

All line references identify the investigated committed sources. Ranges above are source descriptions, not changed lines.

The 32 KiB backing RAM is always instantiated, independent of ROM type. It is not SDRAM or DDRAM. DDRAM holds savestate images, not the live cartridge RAM. The backing is shared among Sega SRAM, Codemasters expansion RAM, Dahjee expansion RAM, Castle/SC cartridge RAM and EEPROM. Thus allocating the hardware does not identify a logical cartridge owner.

For the Sega path, `nvram_a = (nvram_p and not A(14)) & A(13 downto 0)`:

| Guest window | Enable | Physical range |
|---|---|---|
| 8000-bfff | `nvram_e`, $FFFC bit 3 | 0000-3fff when bit 2=0; 4000-7fff when bit 2=1 |
| c000-ffff | `nvram_ex`, $FFFC bit 4 | 0000-3fff regardless of bit 2 |

Both 16 KiB banks retain independent contents simultaneously. Switching/disable changes routing, not storage. The upper CPU window is an alias of physical bank 0, not another bank. Normal Sega writes have no separate SRAM write-protect latch: `!WR_n && !MREQ_n`, selected window, `!ss_freeze`, `!mapper_eeprom` qualify the write. Mapper-register writes while the upper RAM window is enabled can also reach its physical bytes; the decoder has no special exclusion for fffc-ffff. This is existing behavior, not a proposed change.

## 2. Mapper capability matrix

These rows describe register-map behavior after reset with the indicated mode established. They are not immutable hardware ownership assertions. `mapper_set` can restore flags independently of mode and runtime transitions may leave previous flags latched.

| Mode | Sega SRAM selection from clean reset | Selection/banks/write control | Static ownership known? / detection | Persistence |
|---|---|---|---|---|
| Ordinary SMS/GG Sega fallback, including forced Sega | Yes, emulated register path permits it | $FFFC bits 3/4 enable, bit 2 selects lower-window bank; decoded CPU writes | Mapper route known; actual SRAM presence/size unknown. Auto classification can later change route | Shared host policy; writes work without a SAVE mount |
| Generic Korean $A000 bank-write fallback | Yes while still on generic path | Same Sega register fallback plus Korean ROM bank write | No independent SRAM capability; generic fallback is not a SRAM assertion | Same |
| Codemasters, static/forced/locked | Dedicated CME RAM, not two-bank Sega SRAM while Codemasters remains active | $4000 bit 7 enables a000-bfff 8 KiB window, physical 2000-3fff normally; $FFFC cannot update Sega bits while locked/confirmed in cartridge phase | Codemasters mode does not prove a particular cartridge has CME RAM; enable is dynamic. Unlocked auto mode can transition to Sega | Same shared 32 KiB SAVE, no per-mode size selection |
| Wonder Kid | Generic fallback can still accept Sega $FFFC if Codemasters is not active | $8000 ROM bank behavior plus generic Sega register acceptance | Wonder Kid flag is not a no-SRAM guarantee in this RTL | Same |
| 4-PAK | No fresh Sega enable in its active register branch | $3FFE/$7FFF/$BFFF ROM banking | Dynamic promotion; earlier Sega flags are not explicitly cleared by promotion | Same host policy if writes occur via retained flags |
| Zemina/MSX/Nemesis | No fresh Sega enable while `use_zem && bootloader_n` | 0000-0003 ROM banks; BIOS phase can fall through differently | Signatures, CRC/size and manual choice select route, not SRAM capacity | No dedicated Sega persistence criterion |
| Janggun | No fresh Sega enable | Dedicated register branch wins | CRC identifies mapper, no Sega capability flag | Shared storage exists; no ordinary Sega use from clean reset |
| Linear / Sega-locked Dahjee B | No fresh Sega enable | Branch explicitly blocks mapper writes | Manual/heuristic mode, not immutable ownership; previous flags can survive transition | No dedicated policy |
| Dahjee A | Dedicated 8 KiB RAM, not Sega banked SRAM | 2000-3fff via cartridge access qualification, physical 0000-1fff | Mode implies expansion, auto detection can change | Shared SAVE path |
| Castle | Dedicated 32 KiB cartridge RAM | 8000-ffff, physical 0000-7fff | Load signature/mode identifies this topology | Shared SAVE path |
| SC-3000 | Dedicated configured RAM, not Sega mapper SRAM | Explicit 0/2/16/32 KiB selection; see section 9 | Configuration supplies size | Shared SAVE path |
| SG without SC/Dahjee/Castle expansion | No explicit expansion from SG extension alone; generic fallback may still be reachable | `.sg` selects palette, does not authoritatively declare no SRAM | Extension is insufficient as a negative capability | Shared policy |
| EEPROM | No Sega SRAM enable in EEPROM branch | $FFFC bit 7 resets EEPROM wrapper; backing first 128 bytes uses dedicated engine | CRC list provides positive EEPROM identification | EEPROM forces `bk_ena` after download; dedicated v4 savestate payload |
| System E | No fresh Sega enable | Branch blocks Sega banking; separate WRAM/VRAM topology | Platform is known | No Sega-specific ownership flag |
| Evolution | Separate board/storage semantics | Separate controller; not a Sega SRAM ownership source | Separate detected/forced mode | Outside F06; do not reinterpret its snapshot bits |

Negative controls are therefore strongest for established, reset configurations with dedicated branches (EEPROM, System E, Janggun). They must not be generalized to every earlier/later timeline of an autodetected ROM. Forced Sega means suppress competing mapper heuristics, not that the ROM physically has SRAM.

## 3. Static sources and failure cases

| Candidate | Evidence available in repository | False-positive / false-negative problem |
|---|---|---|
| ROM header | Codemasters header bytes at 7fe0/7fe3/7fef; other signatures/scans | These identify mapper candidates, not general Sega SRAM capability. Header-like bytes can occur without RAM; missing/alternate headers do not rule it out |
| ROM length | `rom_size_pages`, cart masks; 32/48 KiB heuristic classifications | Length does not encode SRAM hardware; using a threshold excludes valid different-size games and includes ROM-only cartridges |
| Mapper type | OSD Auto/Sega/Codemasters/Dahjee/Linear/Zemina; detected specialized modes | Sega register family covers RAM and ROM-only software; current auto result can change or be restored from snapshot |
| CRC/database | Existing CRC lists identify EEPROM, Janggun, Evolution and other special handling | No comprehensive positive/negative Sega SRAM table. A future curated table needs dump variants, unknown handling and provenance |
| File index/extension | SMS/GG/SG/SC routing and SC paging detection | Console/file family is not battery RAM capability; renamed files already supported by project notes |
| MiSTer host metadata | `img_mounted`, `img_readonly`, `img_size`; MRA System E configuration | No `cart_has_sram`/RAM-size channel found in `SMS.sv`/`hps_io` or included MRA definitions. An arbitrary/missing/readonly SAVE is not a chip declaration |
| User options | Mapper choice, SC size, persistence and autosave controls | Explicit SC size is useful; no Sega SRAM-present/absent/size option exists |
| Current flags / access history | Guest enable, bank choice, read/write strobes | Good evidence of emulated exposure; not complete pre-access physical capability information |

This is a repository investigation, not a claim about undocumented capabilities of external MiSTer host software. No web research or external database was used. The project's `README.md:38` itself documents that mapper descriptions are absent from ordinary .sms/.gg files.

## 4. Persistence signals mean host policy and activity

| Signal | Exact current meaning | Why insufficient for ownership |
|---|---|---|
| `nvram_e/ex/p` | Current mapper window/bank bits | Guest disable/reset clears them while backing survives |
| `nvram_we` / `bk_save_write` | Current backing write; dirty qualifier excludes ss_freeze | A pulse, includes other owners; reads are omitted |
| `bk_ena` | Writable image mount observed during cart download; EEPROM additionally enables it after download; cleared at eject/new download | No guest-use requirement, readonly/missing mount false negatives, common to all RAM owners |
| `bk_pending` | Dirty marker: cart download rising edge clears; eligible guest write outside OSD sets; full EEPROM restore sets; active backup clears | Saving erases the evidence without erasing RAM. No mount means guest writes need not set it |
| `img_mounted/readOnly/size` | Host image notification, access mode, byte length | Host file availability rather than emulated chip identity; size may be zero on initial file creation |
| `bk_load/save` | OSD request; save also autosave when dirty, OSD open, autosave enabled | An operation request, not a capability |
| `bk_state/loading` | Active backup and load direction | Temporary transfer state; loading also asserts core reset |

Guest disable/bank changes do not themselves clear `bk_ena` or `bk_pending`. `bk_pending` nevertheless clears during SD backup; it cannot be promoted to cartridge-lifetime ownership. The normal automatic load trigger is download falling edge, nonzero `img_size`, and `bk_ena`. Every transfer is 64 sectors x 512 bytes = 32768 bytes, independent of selected SRAM bank or mapper enable. Port B reaches all 32 KiB. Host padding/handling of a shorter file is outside this RTL; a 16 KiB host file does not make the second physical bank disappear.

The SD request block's manual-request edge handling is inherited and does not itself use SRAM capability. It must not be silently redesigned in F06. Future ownership state should not become a new `bk_ena` gate or alter `.sav` byte layout. A restored complete SRAM image should mark dirty under the existing persistence policy and use established SD/savestate exclusion; that implementation still needs tests.

## 5. Reset and cartridge lifetime

| Event | Visibility / classification | Physical backing | Proposed lifetime meaning |
|---|---|---|---|
| FPGA configuration/power-up | Mapper initialized | MIF initializes every byte FF | Start lifetime with no loaded profile |
| Console soft-reset button (`SMS.sv:556`, `rtl/io.vhd:694`) | Only `$DD` bit 4 changes; game decides response | No hardware clear | Same cartridge; preserve learned capability |
| Core reset: RESET/status[0]/buttons[1] | `raw_reset` -> `reset_active` -> mapper RESET_n low, flags clear | No NVRAM reset port/clear | Same cartridge; preserve profile/evidence |
| BIOS load/config changes | Core reset; BIOS handoff also resets SRAM flags | Retained | Same cartridge unless a separate cart event occurs |
| Host SAVE load | `bk_loading` resets mapper; SD writes backing | All supplied bytes replaced | Same cartridge; capability metadata unchanged |
| Savestate load | Mapper snapshot replaces selection flags | Only encoded payload overwritten | Same cartridge; mapper state rewinds, knowledge need not rewind |
| ROM download rising edge | Core held reset, mount eligibility/dirty clear, load detectors restart on ROM bytes | No explicit clear | New cartridge generation, including reloading the same ROM |
| Eject | Core reset, loaded-ROM bookkeeping and bk_ena clear | No explicit clear | End cartridge generation |
| Runtime mapper detection / manual selection | May change permitted register path; some flags survive | Retained | Not cartridge replacement |

`SMS.sv:418-431` clears WRAM during reset, not NVRAM. The 16 Ki-clock WRAM clear extension is irrelevant to backing retention but delays reset release in the complete core. Actual new-cart bytes therefore depend on previous RAM, power-up FF and any host SAVE load; the architecture must not assume every ROM reload reinitializes FF.

## 6. Dynamic characterization

Artifacts: `tests/sram_architecture/prepare.js`, generated `characterization.sv`, `run.do`, `sources.json`, `characterization.log`. Run Node generator from repository root, then ModelSim `-c -do run.do` in that directory. Source hashes are recorded for eight production inputs.

The fixture uses production `mapper_ctrl`, `memory_bus`, `io`, `dpram` and the actual MIF; it extracts the production dirty, mount eligibility and SD-control always blocks verbatim. Guest mapper operations and all bank contents use CPU ports; host loading uses actual RAM port B. The Sega/SC address expression is transcribed from `system.vhd` and its source is recorded. It does not instantiate the complete Z80, ROM transfer/detector or HPS link. It applies their reset/mount/download interface events and supplies SD handshakes; this is not a full-core reload or software execution test.

ModelSim rejects three existing exhaustive binary-only VHDL register cases because STD_LOGIC includes meta-values. A generated simulation-only mapper copy adds `when others => null` in those three cases; production source is untouched. All exercised addresses are known binary values. No functional branch is changed for those values.

Final run: **0 errors**, one Altera mixed-port-read assumption warning (`OLD_DATA`); simulated 12.137946 ms, about 8 seconds wall time. Expected read-after-write checks allow registered RAM latency. No assertion failures. Results:

| Sequence | Result |
|---|---|
| Initial bank-0 first byte / bank-1 last byte | FF from actual MIF |
| Fill bank 0 and bank 1 with distinct address-dependent deterministic patterns | Both entire 16384-byte banks match through guest reads |
| Write -> disable -> re-enable; bank switching and repeated full scans | Both banks retain independent contents, including endpoints |
| No host mount after writes and disable | `ne/nx/np=0`, `bk_ena=0`, `bk_pending=0`, yet data survives |
| Console soft-reset input with actual IO | DD.4 toggles; mapper enable and both complete banks survive |
| Core status reset / RESET input / BIOS-download reset | Visibility clears; both entire banks survive |
| `mapper_set` with zero snapshot / BIOS handoff | Visibility clears; both entire banks survive |
| Cart download without host SAVE / eject | Both entire banks retain old bytes; ownership/persistence indicators absent |
| Writable mount while SRAM disabled and unwritten in new generation | `bk_ena=1`, `bk_pending=0` |
| Guest write, disable, core status reset | Dirty and mount eligibility survive; visibility clears |
| Normal SAVE, all 64 sector handshakes | Dirty clears; mount eligibility and both complete banks survive |
| Manual host load | Both complete banks become C7; mapper reset clears visibility |
| Readonly mount on new download | `bk_ena=0` |
| Change mapper control input to linear after Sega enable | Existing enable remains latched; attempted register disable is ignored in that branch |
| Writable nonempty SAVE at download completion | Automatic host load starts and fills backing through port B |
| SC 2/16/32 KiB selections | Endpoints route correctly, 2 KiB mirrors, zero-size control returns ROM/WRAM |

The runtime linear-input test characterizes mapper-control behavior, not proof that every auto detector naturally produces that exact sequence. Detection lifecycle is traced statically. No new savestate round-trip tests were run: no proposed format or implementation exists. SC tests characterize routing/endpoints, not full-content F05 replay. Existing fix regression suites and Quartus were not rerun for this documentation-only investigation.

## 7. History

- `e24f16f` (2018, “Fix initialization and add save support”) already implements two-bank address selection using `(nvram_p and not A(14))` and host backup addressing with six sector bits. Two-bank retention is inherited, not introduced by recent savestate work.
- `e83c55ad` (2021 blame origin) supplies the dirty and backing-store persistence structure. Later edits do not turn it into capability metadata.
- `077545e` introduced savestates with an 8 KiB Dahjee-only transfer.
- `8f3bcb2` broadened selection to 8/16/32 KiB from mapper flags and extended addresses/counters. Its diff establishes the visibility-derived predicate's incremental origin; it does not document independent ownership or justify omitting disabled backing.
- `9dfc107` adds EEPROM handling, FF initialization and EEPROM host eligibility. RAM was already 32 KiB beforehand.
- `99dbeee` and `dd83b49` extract mapper banking and memory decode/bus into modules. The topology predates these refactors.
- `b0f4b71` adds EEPROM backing/protocol coherency and persistence exclusion. Its dedicated owner must remain distinct.

There is evidence of intentional 32 KiB physical retention and host transfers, and an incremental savestate selection gap. No historical authoritative Sega SRAM presence field was found. This does not establish the original authors' intent for every ROM-only cartridge.

## 8. Architecture comparison and T0-T3 semantics

| Option | Correctness and false positives/negatives | Savestates / reset / cartridge change | Cost and maintenance |
|---|---|---|---|
| A: static `cart_has_sram` | Exact only with authoritative profile. Mapper family/header/length/file existence alone yields both false positives and negatives | Capability is cartridge metadata, preserved on soft/core reset, replaced on cartridge generation. Full backing included from first snapshot | Simple consumers; incomplete database/config channel is the hard problem |
| B: sticky lifetime discovery only | A qualified enable or SRAM read proves emulated accessibility before writes. Write-only detection misses read-only and initialized-data behavior. No event proves absence before first use | Keeping learned knowledge after load avoids forgetting capability, but cannot restore bytes omitted at T1. Rewinding bit to zero also cannot recover them | Small latch, substantial semantic hole; reject as sole selector |
| C: mapper-specific capability | Good for explicitly configured SC, Castle/Dahjee expansions and EEPROM. Sega family alone still has unknown presence; auto type is mutable | Must distinguish stable profile from restorable classification and retain discovered evidence through redetection | Clear typed owners, additional matrix maintenance; insufficient alone |
| D: static + runtime hybrid, explicit unknown | Authoritative positive/negative entries plus qualified observed-use evidence. Unknown remains unknown until evidence arrives; absence is never inferred from lack of use | Metadata is not rewound. Snapshot payload validity/owner/size is serialized separately. Unknown needs a complete-backing or reject/defer policy from first snapshot | More explicit state; most maintainable because uncertainty is represented, not hidden |

For T0 load / T1 save before discovery / T2 enable+write / T3 load T1: learned cartridge capability should remain learned. Restoring `sram_seen=0` confuses time-dependent observation with cartridge knowledge. However, **keeping it at 1 also does not recover the missing T1 bank image**. Therefore a sticky latch by itself cannot satisfy F06 for this timeline. Capture backing before discovery, preserve an exact earlier image by some separately proven mechanism, or refuse to claim a complete snapshot while ownership is unknown. Assuming FF at T1 is invalid because ROM reload retains bytes and SD can preload data.

A bare bank-bit write with both enables zero is insufficient evidence of exposed SRAM. A committed enable that actually selects SRAM is sufficient evidence of emulated reachability; it need not wait for a write. A read should count too, including before the first write. A write-only latch also misses effects of host-loaded data. Discovery must use the effective selected owner and exclude EEPROM, SC and expansion owners; it cannot watch raw `nvram_we` globally.

## 9. Proposed implementation contract (not implemented)

Recommend **D**, with `cart_ram_profile` as a typed descriptor rather than one ambiguous bit:

- Fields: cartridge generation identity, owner (`none`, `sega_sram`, `sc_ram`, other dedicated owners), byte count, capability certainty (`authoritative`, `observed`, `unknown`) and provenance.
- Generate in cartridge configuration/lifetime control at the top-level boundary, using validated static metadata if available and qualified effective-owner events from mapper/memory routing. Do not derive a cartridge-lifetime field in a RESET_n-cleared mapper process.
- New ROM download rising edge starts a generation; eject ends it. Core/mapper/console reset, BIOS replacement, host SAVE load and savestate load preserve metadata for the same cartridge generation. FPGA configuration initializes it. Same-ROM reload is still a new generation because host SAVE loading and loader bookkeeping repeat.
- A validated Sega-positive profile or qualified exposure promotes to Sega owner with **32768 bytes**, not the selected 16384-byte window. Never infer Sega ownership from EEPROM traffic or SC writes. Existing dynamic classifier changes must not erase learned evidence; conflicting owner evidence is explicit, not silently overwritten.
- A proven-negative profile becomes `none` only from a reliable source for the complete loaded cartridge, not from a currently inactive enable or transient heuristic. Current architecture cannot supply this for every Sega-family ROM.
- Capability/learned knowledge is not savestated as a rewindable emulated latch. Snapshot metadata **must** record validated owner, payload size and presence, because a loader must know what was actually captured. Mapper visibility and bank selection remain existing emulated snapshot state.
- Normal `.sav` eligibility/size/timing remain current policy. `bk_ena` stays host eligibility; `bk_pending` stays dirty. SRAM restored from a valid payload should set dirty when persistence can use it; an SD transfer must finish before freeze, and queued requests wait for release. Do not force SRAM visible.
- All owned Sega snapshots include physical 0000-7fff, both banks together. A subsequent read after bank switches must see the saved values. There is no basis for a 16 KiB-only ownership size in the generic implementation while bit 2 can expose the second bank.

**Unresolved implementation prerequisite:** choose an authoritative source for unknown Sega cartridges, or explicitly adopt a conservative emulation contract that captures the shared 32 KiB for every still-potential Sega owner from the first snapshot. The latter is complete for future emulated accesses but includes bytes for some physical ROM-only cartridges. It must be named as reachable backing, not asserted physical capability. The typed profile alone cannot create information that ROM input does not contain. No new external source has been proved here.

Legacy snapshots: untagged and v1/v2/v3/v4 contain no new profile descriptor. Preserve current cartridge knowledge; never read old unused bits as presence. Restore exactly the historically encoded physical range, leaving absent second-bank/SC bytes untouched. In the old 64 KiB format the SRAM path was Dahjee-only. Later historical formats use existing flags: 8 KiB Dahjee/CME, 16 KiB when only Sega enable applies, 32 KiB with ex/p/Castle. Even legacy bank-1 visibility does not mean a 16 KiB payload started at bank 1: the DMA always began at physical zero. Missing data cannot be recovered. Future metadata must be independently validated against the current cartridge/profile. Version/layout design belongs to the implementation task.

### Independent F05 contract

SC ownership and required size are explicit: `sc3000_en && sc_cart_ram != 00`; 01=2048, 10=16384, 11=32768 bytes. Preserve that exact physical prefix through savestate DMA independent of Sega flags; do not allocate another live RAM. SC configuration is stable during ordinary execution but can change in OSD, generating a configuration reset (`SMS.sv:396`). Backing survives that reset. Capture and validate SC mode/size with the snapshot, and define mismatch handling explicitly (reject incompatible configuration rather than guess or silently change user options). Same-configuration reset must not erase retained state. Zero-size SG/SC must not receive a fabricated payload. SC legacy payload absence leaves current backing intact. EEPROM remains a separate owner/path.

**F05 can safely be fixed independently**, subject to its original dynamic reproduction, freeze, layout, version, legacy and persistence tests. Splitting it avoids coupling a known configuration fix to the unresolved Sega capability policy. It is not implemented here.

## 10. Next tasks and remaining ambiguities

1. F05-only implementation task using explicit SC configuration, with requested full-range replay/DDRAM/persistence and previous-fix regression coverage.
2. Resolve F06 unknown ownership policy: either supply trusted per-cartridge capability metadata (including how unknown/alternate dumps are handled), or authorize conservative capture of potentially reachable backing before first use. A sticky-bit-only implementation is insufficient.
3. After that decision, implement the typed lifetime contract, validated payload metadata and full 32 KiB Sega transfers. Include T1-before-first-use replay, readonly/missing SAVE, same-ROM reload and runtime classification transitions in tests.

Additional observed ambiguities, unchanged: cartridge replacement/eject preserves previous physical bytes; runtime mode transitions do not necessarily clear old SRAM enable flags; raw backing traffic combines several owners; SC size is user configuration and can outlive/change independently of a saved timeline. These require explicit contracts, not adjacent mapper-detection or memory-clear fixes. No F13/Evolution/accessory behavior was changed.

Scope verification: production and staged diffs empty; `git status --short` remains `?? tests/`. This review is under ignored `output_files/`; new fixtures are under the pre-existing untracked tests tree. No commit, push or PR. No production workaround or format change. Full-core/hardware host behavior beyond the modeled interfaces remains unmeasured.

ARCHITECTURE UNRESOLVED - MORE EVIDENCE REQUIRED
