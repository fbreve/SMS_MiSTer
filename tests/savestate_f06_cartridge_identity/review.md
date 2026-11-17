# F06 MiSTer host/cartridge identity investigation

**Decision E. SMALL FRAMEWORK EXTENSION IS REQUIRED** for the retained F06 contract: preserve same-cartridge RAM, prevent new-cartridge inheritance of foreign retained RAM, and make complete savestates portable under an explicit cartridge association. Existing MiSTer provides per-name file selection, not an unconditional ROM-content/retained-SRAM ownership guarantee. No production or framework change was made.

**The Phase12 conditional answer is YES:** if a savestate is guaranteed to belong to the loaded ROM, restoring all32 KiB plus existing mapping state is sufficient for SRAM replay; FPGA ownership/generation metadata is unnecessary for that narrower contract. Full capture preserves whatever bytes were actually observable at SAVE. It does not, by itself, initialize a newly loaded cartridge's RAM. The distinction is why the conditional answer does not establish decisionA for all requirements of this investigation.

This report does not recommend cryptographic authentication, a new FPGA hash engine, or broader cross-ROM protection for every core. A source-demonstrated missing-save lifecycle gap and namespace aliasing are the concrete reasons the stronger ownership premise cannot be assumed. If the intended F06 contract is instead explicitly limited to replay under correct same-ROM input, the RTL-only full32 KiB architecture below is already sufficient; that is a scope decision, not a host guarantee discovered here.

## 1. Current HEAD and evidence scope

`7fcd5e12847eedf9e97a44dc937c3dbac3205f7c`; branch `investigate/savestate-f06-cartridge-identity`. Both requested prerequisite reports were read completely. [baseline.json](baseline.json) records their hashes and all204 tracked regular-file hashes. No AGENTS.md was found in the repository search or checked parent directories.

Host implementation inspected: **MiSTer-devel/Main_MiSTer at bfb5cd0e7787da124017f604710d4916647442ef**, commit date2026-10-27T09:23:42Z. [host_provenance.json](host_provenance.json) pins the commit/tree and eight Git blob IDs, including SPI helpers. All downloaded files independently match their Git blob identities. This is an upstream source snapshot, **not an attestation of the user's installed MiSTer binary/version**. Source copies are under [host/](host/).

Primary source links: [host ROM/persistence/state implementation](https://github.com/MiSTer-devel/Main_MiSTer/blob/bfb5cd0e7787da124017f604710d4916647442ef/user_io.cpp), [filename generation and file IO](https://github.com/MiSTer-devel/Main_MiSTer/blob/bfb5cd0e7787da124017f604710d4916647442ef/file_io.cpp), [menu selection](https://github.com/MiSTer-devel/Main_MiSTer/blob/bfb5cd0e7787da124017f604710d4916647442ef/menu.cpp). Line references below refer to these pinned copies or unchanged checkout RTL.

## 2. v17 confirmation and capacity

Production remains v17: FM_MAGIC484311, subtype3,96 KiB slot,0x3000 DDR64 stride; current header/gameID validation and all existing payloads unchanged. No future format number is assigned.

Retained F01 baseline:37,175 needed ALMs; **38,598/41,910 placed (92.097%)**;48,948 fitted registers;488/553 M10Ks;3,818,050 memory bits;39 DSP; setup **+0.105 ns**, hold **+0.206 ns**; zero failing timing-summary categories. Existing partially unconstrained paths limit signoff. No Quartus build or resource optimization was performed here.

## 3. Complete ROM-download lifecycle

Normal SMS menu entries are `H8FS1,SMSSG SC` and `H8FS2,GG` in SMS.sv:215–216. `S` in the F option requests opening associated save storage. The host menu builds the download index from extension ordinal and menu index (menu.cpp:2505–2546,2778,2845), then calls user_io_file_tx.

The ordinary non-composite, non-direct-memory SMS sequence in user_io.cpp:2833–3076 is:

1. Open selected ROM, determine file length, choose menu/extension index.
2. Send FIO_FILE_INDEX55; send FIO_FILE_INFO56 with up to four uppercased extension characters, including the dot.
3. Send FIO_FILE_TX53 nonzero to start download. For ordinary SMS load_addr=0, no explicit size/address argument is sent here.
4. Call process_ss(name) while download is active, before the ordinary ROM-byte loop. This initializes the four DDR state slots from files selected by the ROM name.
5. Send file bytes in up-to4096-byte chunks using FIO_FILE_TX_DAT54. Backpressure is handled through the framework/ioctl_wait path; the core records byte addresses/data/strobes and writes ROM.
6. Finish host CRC/logging, close ROM, generate `.sav` path and call user_io_file_mount(path,0,pre=1,pre_size default0).
7. Mount sends size first (UIO_SET_SDINFO1d), then drive/read-only notification (UIO_SET_SDSTAT1c), **before** FIO_FILE_TX0 ends ROM download.
8. Falling cart_download permits the SMS persistent-load decision. A nonzero writable image starts64-sector load; bk_loading keeps guest reset until completion, followed by existing WRAM reset clearing.

SMS.sv:436 includes cart_download in raw_reset. SRAM itself is not reset or cleared by this signal. Core reset and ROM download are different from FPGA reconfiguration, which reapplies nvram_ff.mif.

`spi_write` sends each byte through spi_b/fpga_spi for WIDE0; `sys/sys_top.v:232–263` exposes the io_ack/width/read-data path and holds acknowledgment for io_wait. This is transport flow control, not cartridge metadata. Generic startup boot.rom/bootN.rom fallback calls in user_io.cpp:1691–1717 use opensave=0 by default (user_io.h:227), so they do not automatically take the menu-FS per-ROM persistence/state association path. Arcade/MRA explicitly calls process_ss(xml) at1656. These paths must not be described as a universal per-download filename/ownership guarantee; the sequence above is the normal SMS FS menu path.

## 4. Signals actually observable by FPGA

|Signal/information|Framework exposes|SMS consumption / meaning|
|---|---|---|
|ioctl_download|active level; rise/fall|cart_download classification and guest reset|
|ioctl_wr|registered byte-valid pulse|ROM write/metadata update|
|ioctl_addr|27 bits in framework; byte addresses at WIDE0|SMS25-bit connection; start0, increment on data, end address after last byte|
|ioctl_dout|8 or16 bits by WIDE|SMS WIDE0 uses8 bits|
|ioctl_index|16-bit register|SMS consumes8; host ordinary API sends8|
|ioctl_file_ext|four character bytes|SMS consumes it for file-type/mode selection|
|ioctl_upload/rd/din/index|upload protocol|No cartridge filename/identity; unconsumed upload capability is not a hidden owner field|
|img_mounted|drive-bit notification pulse|SMS one drive; event, not image identifier|
|img_readonly|mount attribute|SMS suppresses bk_ena on readonly mount|
|img_size|64-bit mounted-image size|SRAM file size, not ROM identity; zero may mean deferred creation or empty file|
|sd_lba/buffer/ack|sector transaction signals|address/data/completion, no owner token|
|status, RTC, timestamp, SDRAM size, EXT_BUS|settings/general metadata|No standard cartridge identity field in the inspected interface|
|ROM filename/path|host has it|Not sent; file_info transmits extension only|
|ROM checksum/hash|host and FPGA compute some|No standard host ROM-CRC/owner transfer on SMS path|
|cartridge generation|download boundaries can be counted locally|No stable same-cartridge/new-cartridge assertion|

`sys/hps_io.sv:618–703` is the actual file decoder. [interface.log](interface.log) runs its **verbatim extracted production FIO block** with host protocol commands: identical downloads yield identical16-bit-index/address/data traces; a changed stream changes bytes but not the metadata envelope; 16-bit index0041/ab41 behavior is checked. This is a decoder component test, not a full HPS/ARM co-simulation. The complete hps_io module was not modified.

## 5. ioctl_index semantics

Normal user_io_set_index accepts unsigned char. `user_io_set_aindex` can send16 bits for specialized cores. Generic menu code uses `(extension_ordinal << 6) | menu_index`; high two bits select an extension within the F entry, low menu index selects the loader target. SMS accepts1 for SMS/SG/SC families,2 forGG,3 for SMS BIOS,4 for GG BIOS,254 for system/DIP metadata and255 for cheats, with existing masking rules.

The same index is reused for arbitrarily many ROMs of that type. It is neither a monotonically unique image number nor an SRAM file identity. The full16-bit framework output is not an unused exact cartridge ID; ordinary SMS host transfers provide no such semantics for its upper bits. Drive0 in image mounting names a virtual storage slot, also reused across cartridges.

## 6. Same-ROM reload sequence

Selecting the same ROM again repeats index, extension, download start, full byte stream, state-slot reload, associated save mount and download end. No same-cartridge flag is sent. A writable existing `.sav` is loaded again by SMS, replacing unsaved SRAM changes. If missing/empty/readonly, the auto-load condition fails and old physical SRAM remains. State slots are reinitialized by process_ss even on a same-ROM reload; their change detector resets to ffffffff.

The prior test's retained data on a reload without persistent replacement is consistent with this host path. It is not universal “reload retains newest RAM” behavior: an existing file intentionally wins on reload.

## 7. Different-ROM sequence

SelectA thenB: the metadata envelope is the same if file types match. ROM bytes/length can differ; host filesystem paths can differ without any corresponding path signal at the FPGA. State files and mounted saves are selected anew from B's basename. No final “B ownership established” event is guaranteed for zero-size or read-only storage. Different byte streams are observable during download, so “same and different downloads are indistinguishable in all cases” would be false. Their **lifecycle metadata alone** does not discriminate identity.

Two different filenames with identical bytes can produce the same complete download observations; their host save namespaces may still differ. Conversely two distinct byte streams can collide in the current finite FPGA signatures, as the retained prior actual-RTL collision proves. There is no signal that repairs either distinction automatically.

## 8. Explicit identity availability

The host knows the selected path, basename and file contents. hps_io does not expose them as a cartridge ID. File extension, index, drive number, mounted size, timestamps and SD configuration/CID are not stable cartridge identities. UIO_SET_SDCONF describes emulated storage configuration; it does not carry the selected ROM name. Logging files `/tmp/GAMEID`, `/tmp/FULLPATH`, `/tmp/CURRENTPATH` are host files, not an FPGA protocol.

Thus the existing interface contains a **load event and byte stream**, plus persistence attributes. It lacks an authoritative owner/same-cartridge assertion bound to the retained physical SRAM. A completed persistence transaction establishes that bytes were supplied for the currently mounted file, but does not by itself establish which ROM content owns that filename or cover the no-transaction cases.

## 9. Existing checksum/CRC and database information

|Existing information|Location / scope|Reusable / limits|
|---|---|---|
|ss_game_id rolling32|SMS.sv:561–569, current v17 word1 upper32|Already guards ordinary wrong-ROM state loads; weak fingerprint, no owner binding|
|full-ROM IEEE CRC32|mapper_detect.vhd:96,505–519, output to system|Already computed during ROMEN; no new CRC datapath needed; would require old-owner latch/completion wiring|
|last8 KiB CRC16|mapper_detect.vhd|Mapper quirks, not whole-ROM identifier|
|header cart_id/product bytes|SMS.sv:660–672|Ys quirk; not unique|
|host file_crc CRC32|user_io.cpp:2950,3024,3050|Cheats/game docs/logging; not sent to FPGA as owner|
|host `/tmp/GAMEID`|user_io_write_gameid2693–2740|Conditional logging; optional, not persistence naming|
|cheat database CRC lookup|cheats.cpp and menu.cpp:2848|Host-side game selection, not SRAM validity|
|MD5 library|host repository lib/md5|Availability is not evidence of an SMS owner transaction|

Host CRC skips an initial `file_size & 0x3ff` bytes in the generic loop. FPGA CRC sees ROMEN bytes; rolling ID also includes selected address bits. These are not automatically the same canonical fingerprint. SMS can compensate512-byte copier headers in ROM mapping via cart_mask/cart_mask512; source identity and equivalent guest ROM mapping remain distinct. Do not silently reuse a checksum under an assumption that every representation hashes identically.

## 10. Local fingerprint feasibility

A download-only fingerprint can run on existing byte-valid strobes, finalize at download end and retain the completed value across soft/core reset by excluding it from reset, as existing static metadata does. It must not reset the *previous owner* latch before comparison with the newly completed fingerprint. It adds no reason to gate runtime SRAM accesses with a CRC combinational cone.

Size alone is immediately available from final address for ordinary contiguous downloads; a counter is needed if handling arbitrary sparse/nonzero-start transfers. CRC32 already exists. Additive checksum/CRC16 could be small, but are weaker. Any fixed-width hash remains non-injective. Raw stream size/checksum distinguishes ordinary reloads deterministically only when host normalization/header treatment is fixed; equivalent headered/raw dumps can produce different IDs despite the same guest program. None proves that retained bytes were initialized for that ID.

No fingerprint implementation was created. Estimates and collision classifications appear in26–27; stronger cryptography is not justified for this task.

## 11. Persistent-save identity architecture

`FileGenerateSavePath` (file_io.cpp:985–1012) constructs `saves/<CoreName2>/<ROM basename with final extension replaced by .sav>`. ROM directory is discarded. File contents/CRC are not part of this key. For example `/games/Japan/Game.sms` and `/games/Europe/Game.gg` both select `saves/SMS/Game.sav` when hosted under the SMS core name. This is a source-bound modeled example, not a claim that these fictitious files exist.

The association lives in the host's `sd_image[0]` object/path and file descriptor. The FPGA gets drive0, size and readonly, not the key. A mounted writable file is useful evidence for a file-backed SRAM transaction, but does not prove cartridge capability/size or every-byte provenance. Backup files can also be copied/replaced externally; the host does not authenticate their contents against ROM bytes.

## 12. Persistent-save transaction lifecycle

The mount occurs while cart_download remains high. Existing writable, nonempty `.sav`: core starts64 sectors at download end, remains reset through bk_loading and writes all32 KiB through RAM portB. Runtime backup reads the full array through portB and writes sectors to the mounted host object. It is independent of current Sega enable/bank flags. Core ss_busy/storage_busy prevent standard competing transactions; explicit persistent requests during SS are queued by current RTL.

For A-load/fileA/runtime/B-load/fileB and A-load/fileA/A-reload/fileA, the same transport pattern is used. No file owner token or differing reload opcode is present. If both completed loads replace all32 KiB deterministically, they create a usable operational initialization boundary. It is not universal, because absent/empty/readonly files do not start that load.

The host servicing code has important edge cases. Missing precreated storage is type2; an explicit requested read gets FF for SMS. Existing-file reads beyond EOF that fail produce zeros, not type2 FF. `FileReadAdv` returns a positive short fread without clearing the unread tail; the caller treats any positive result as success. A final partial read can therefore carry old host-buffer tail bytes. These are source-bound observations, not a new filesystem/hardware regression or an authorized host fix. No universal canonical short-file initialization contract is inferred from a successful SD ack.

## 13. New-game/no-save-file behavior

`user_io_file_mount(path,0,1)` uses default **pre_size0** (user_io.h:195). On open failure it marks writable deferred-creation/type2, records the future save path, sends size0 and a mount notification. SMS sets bk_ena on that writable mount, but its falling-download auto-load predicate also requires `|img_size`; size0 means **no SRAM-read transaction**. Old physical SRAM survives. The same occurs for an existing empty file; a read-only file fails bk_ena and is not automatically imported by SMS.

At initial FPGA configuration RAM startsFF from the MIF. After A→B without a file, B can later expose A's bytes using ordinary FFFC enable/bank writes. Games that never expose SRAM have no guest-visible consequence; the unused bytes can nevertheless become relevant in another loaded cartridge/session. Absence of an access is not proof that SRAM will never be exposed.

Correct fresh-cartridge initialization, if required, must cover all potentially visible bytes before release even with no `.sav`. Neither host deferred creation nor a mount pulse currently performs that initialization. This mandatory case prevents decisionC based solely on persistent completion.

## 14. Savestate host association

`process_ss` (user_io.cpp:2014–2139) maps four configured DDR regions, clears the mapped regions, and reads `.ss` files selected by the ROM name. The first slot prefers `_1.ss`, falling back to unsuffixed `.ss` if absent; slots2–4 use `_2.ss` etc. It sets the first32-bit control word to ffffffff. Later polling detects changed counters and persists `(size+2)*4` bytes to those names.

`FileGenerateSavestatePath` (file_io.cpp:1014–1040) constructs `savestates/<CoreName2>/<basename without final extension>_<slot>.ss` (Arcade has a distinct subdir policy). Thus A→B changes the normally available slot files, and returning toA loads A's files again. The SMS UI issues slot SAVE/LOAD requests through status/keyboard/gamepad; it does not normally browse arbitrary state files. This is a useful per-game namespace mechanism.

The [official savestate API documentation](https://mister-devel.github.io/MkDocs_MiSTer/developer/savestates/) defines the shared DDR/control-word persistence interface; it does not supply restoration of the core's internal state or an explicit cartridge-owner API. The pinned implementation, rather than an assumed filename guarantee, establishes the actual association analyzed here.

## 15. Cross-ROM savestate policy and limits

The generic host does **not** compare `.ss` content with loaded ROM content before placing it in DDR. It validates neither the SMS gameID nor an SRAM owner record. Normal selection provides per-name slots, not a cryptographic or mathematically unique media identity. Different directories/extensions with the same basename collide; replacing a ROM while retaining its basename, or copying/renaming an `.ss`, can present the wrong state. The basename collision is possible through ordinary file selection, not only a malicious HPS transfer.

Current SMS adds a separate v17 check: word1 magic plus ss_game_id equality before restore. This catches ordinary differing rolling IDs. Legacy64 deliberately lacks gameID. Constructed equal rolling-ID and CRC32 streams already exist in the prior report; no new collision search was necessary here. Neither the existing guard nor normal host naming is an unconditional exact wrong-ROM rejection guarantee.

The framework therefore delegates opaque state interpretation/validation to the core; there is no discovered requirement that every core add strong ROM authentication. Preserve the SMS guard. Do not misrepresent ordinary per-name convenience as proof that any presented slot has the right ROM bytes.

## 16. Actual host-contract analysis

There are two different statements:

* **Replay contract:** loaded media/configuration and future external inputs match the snapshot; the host supplies the intended per-game state. Complete stored SRAM is sufficient. The original coverage audit explicitly uses the same-media precondition. This contract does not require proving historical ownership inside the FPGA.
* **Strict lifecycle/ownership contract retained in the preceding F06 request:** never expose another cartridge's retained SRAM; preserve immediate same-ROM retained data when no replacement occurs; support pre-access capture and portable state association. Existing signals do not establish that contract in every required branch.

The host source proves normal per-basename selection, and also proves its limits and the no-file no-initialization path. This investigation does not silently replace the second contract with the first. Its decisionE concerns the second; no stronger cryptographic security contract is introduced.

## 17. Mandatory full32 KiB analysis under guaranteed state identity

Assume the presented state belongs toA, including loaded ROM/mapper configuration. Sequence: loadA; establish SRAM A; SAVE A; loadB/establishB; reloadA (its file might now differ); LOAD stateA. Full physical32 KiB restoration overwrites both banks with the saved A bytes while frozen, installs the saved enable/bank controls, then releases. Current contents, B's history and today's persistent A file become irrelevant to that replay. No owner/generation/fingerprint payload is required for SRAM reconstruction under this assumption.

The proof also covers disabled SRAM, SAVE before first access and subsequently changed persistent storage. Always storing the actual retained array preserves its future observability. Capturing stale bytes already visible in the saved A machine does not create a replay discrepancy. It also does not prove those bytes were originally initialized forA. Thus “full capture solves F06 replay” and “full capture does not solve fresh-cartridge isolation” are simultaneously true.

If strict isolation is dropped by an explicit scope decision, the precise minimal architecture is: full32 KiB for ordinary Sega-reachable RAM irrespective of flags, new complete-payload marker, current mapper metadata, current gameID policy, existing DMA/arbitration; no host change. **That conditional architecture is not selected as an unconditional existing-host guarantee.**

## 18. Stale-SRAM analysis

|Candidate contract/event|When B may safely claim RAM|A→B without save|
|---|---|---|
|Exact replay of actual saved machine|No provenance claim needed; preserve every observable byte|Full capture faithfully preserves existing retained data|
|Completed full persistence import|After all bytes deterministically replaced for associated current media|No completion occurs automatically for missing file|
|ROM start/end alone|Never proves contents changed|A remains physically present|
|Local generation increment|Labels an event, does not initialize data|A can be mislabeledB|
|Finite ROM fingerprint plus owner tag|After identity comparison **and** defined retain/new-owner initialization|Comparison alone does not clear stale bytes|
|Authoritative host context plus core readiness|After approved retain or full initialization/import, before release|Can explicitly initializeFF rather than inheritA|

Nothing makes a mount pulse alone certify the previous contents asB's. For a ROM that never maps SRAM, retained bytes are harmless to that ROM's future under fixed mapping/configuration; no reliable exhaustive no-SRAM profile is supplied by the host. An UNKNOWN capability must remain conservatively full32 KiB.

## 19. Cartridge-generation model

Each download can increment a local counter. This distinguishes transactions but treats every same-ROM reload as new. Assigning ownership only after persistence completion works for a completed fully defined file import, not for no file, readonly, empty file, delayed load, partial/failed reads or SAVE before completion. The current core blocks standard SS acceptance while storage_busy, but cannot wait for a transaction that is never requested.

A saved generation becomes invalid after reboot, returningA followingB, or using another MiSTer instance. Persisting it in the state would either reject legitimate same-ROM returns or relabel foreign RAM without evidence. Counter wrap is another issue. Generations remain useful as temporary response/cancellation labels; they are not portable identity.

## 20. Candidate A — no identity, lifecycle alone

**EXACT UNDER EXISTING MISTER CONTRACT only for same-media replay with the correct intended state supplied.** Full32 KiB is sufficient under that explicit precondition, including all reset/reload/instance transitions when the same image and valid state are provided. This candidate cannot certify wrong-ROM exclusion or initial SRAM provenance; present lifecycle does not always initialize new-game RAM. Normal slot naming is not an unconditional identity guarantee, so A is not selected for the strict requirement.

## 21. Candidate B — generation counter

**INSUFFICIENT** for portable ownership. It survives a soft reset only if deliberately retained; FPGA reload/reboot loses it; same-ROM reload changes it; A→B→A changes it; another instance has an unrelated count. Carrying it in the image cannot prove media identity. Small hardware does not repair these semantics.

## 22. Candidate C — ROM size plus checksum

Size-only and additive sums are **HEURISTIC**; CRC16 is too weak for a general cartridge namespace. Full CRC32 plus stream length is **PRACTICALLY UNIQUE BUT NOT MATHEMATICALLY EXACT** for non-adversarial collections. It can reuse existing CRC hardware and serve an ordinary wrong-ROM guard, provided normalization is defined. The prior same-length CRC32+rolling collision rules out calling it exact for all byte streams.

A correctly retained old-owner ID could guide ordinary same/different reload handling, but must be coupled to initialization on a new owner and explicit behavior for UNKNOWN startup. This is a practical RTL policy option, not a proof of the requested exact lifecycle. It adds a new fingerprint-owned lifecycle contract rather than discovering one already present.

## 23. Candidate D — explicit host-provided cartridge ID

Currently absent. **EXACT under an explicit authoritative host-identity contract**, not automatically exact merely because the field is called an ID. A filename hash or UUID truncated to a few bits is still finite/probabilistic. The host can instead decide exact same/new ownership within its authoritative media model and bind portable state selection to that model. If content equality is the required definition, it must compare canonical bytes or retain an exact reference; a path alone does not detect file replacement. This keeps the comparison out of FPGA runtime logic.

The hardware needs a small context/action/ready handshake; sending a large cryptographic digest is not intrinsically required. Portable state validation can be host-side if the new contract guarantees it. Strong fingerprint authentication is outside scope.

## 24. Candidate E — persistent transaction identity

**INSUFFICIENT as currently implemented.** Drive0 and64 completed sector acks certify transport completion for the current mounted host object, not the ROM associated with its basename. Missing file produces no automatic transaction. A future authoritative owner context plus full deterministic import can establish ownership; the transaction alone is not a stable portable key. Core reset/reboot/another instance must reopen the same association, not reuse a stale drive number.

## 25. Candidate F — other framework identifiers

Menu index, extension ordinal, img_size, mount pulse, SD CID/configuration, RTC, timestamp, optional `/tmp/GAMEID`, host cheat CRC and core name are **INSUFFICIENT** individually. File/type metadata can remain identical for different cartridges; generic timestamps change on reload and are not cartridge identities. No unconsumed standard hps_io signal with exact ownership semantics was found. Adding an EXT_BUS convention would itself be a framework/API extension, not reuse of an existing guarantee.

## 26. Collision/exactness requirement

This is correctness identification, not protection against a malicious user. Practical CRC32 collision risk may be acceptable for a separately approved ordinary guard; it must not be marketed as mathematically exact or used to infer missing historical bytes.

|Identifier|Random pair collision / weakness|Normalization / reset behavior|
|---|---|---|
|Size only|Every same-size pair collides|Headered versus raw length changes; cheap count survives only if retained|
|Additive16/32|Approx2^-16/2^-32 under ideal assumptions; byte reorderings and compensating changes trivial|Order-insensitive; new counter/latch needed|
|CRC16|2^-16 random pair; unsuitable large namespace|Existing last-block CRC is not even whole ROM|
|CRC32|2^-32 random pair; linear constructed collisions; birthday risk over many images|Existing full stream CRC retained across ordinary resets; canonicalize headers if equivalence desired|
|Current rolling32|Not a standard robust CRC; constructed collisions|Already in v17; recomputed during download, not an SRAM owner|
|SHA256/stronger hash|Negligible practical collision, still not mathematical injectivity|Substantial new engine/byte normalization; unjustified for minimal task|
|Host authoritative same/new assertion|Exact to the defined host media relation|Must define file replacement/equivalent formats and survive state selection appropriately|

For a fixed known ROM compared against a randomly unrelated file,32-bit CRC collision probability is about1/2^32 under the usual random-error model; this is not a general guarantee or the collision probability for an entire large library. A stronger hash does not initialize RAM or distinguish two save namespaces for identical content. Reusing mapper CRC32 is preferable to duplicating checksum logic if a practical policy is chosen later.

## 27. FPGA resource estimates

No synthesis was run; estimates are structural planning ranges, not fitted deltas. Existing shared SRAM, DMA15-bit addresses/12-bit word count and pack buffer already support32 KiB. Added full capture needs no duplicate SRAM, scratch M10K, DSP or broad parallel restore mux.

|Option|Added registers / state|ALM planning scale|M10K|Runtime timing/fanout|
|---|---|---|---:|---|
|Full32 KiB plus presence|roughly1–16 FF/control bits|10–100|0|Existing sequential DMA controls only|
|Size count/old-size latch|up to27 bits each; existing address may replace count|10–60|0|Download-only updates; small end comparison|
|New additive32|32 accumulator+32 old ID, plus size if used|20–100|0|8-bit add during download; no SRAM runtime path needed|
|New whole-ROM CRC16|16 current+16 owner bits if existing last-block one cannot be reused|20–100|0|Byte XOR network on download CE|
|Reuse existing CRC32|0 new running CRC bits;32 owner+ready/valid, optional old length27|20–150|0|End-of-download equality/control; CDC/completion must be resolved|
|Local generation32|32 current+32 owner+valid|20–150|0|No identity benefit; avoid pointless extra payload|
|Host action/ready context|roughly4–16 control bits plus optional transaction label|20–150|0|Load-time handshake and existing reset/hold; no per-byte owner mux|
|New SHA-class engine|Hundreds of state/schedule bits or more, architecture-dependent|Hundreds to thousands, not estimated as a fitted budget|0–several|Download timing and placement risk; not selected|

Ranges are deliberately broad. A32-bit compare may fit far below its range, while global physical remapping may exceed a local estimate. Setup reserve+0.105 ns makes an early controlled Quartus gate mandatory for any eventual RTL change, after functional sufficiency. No claim that unmeasured logic is free or will fit.

## 28. Minimum framework-change requirements

For the strict contract, define an **opt-in cartridge-context transaction** around the existing download, not a general host redesign:

1. Host identifies whether the just-loaded cartridge is the same owner of the retained array (`RETAIN`) or a new owner (`INITIALIZE`). The assertion must be authoritative under a documented identity relation; comparing loader index/extension is forbidden. If ROM-byte identity is required, the host must distinguish file replacement and normalization correctly.
2. On INITIALIZE, core holds guest and SS acceptance until all32 KiB is initialized deterministically (FF plus associated file bytes, with defined short/readonly/missing-file policy). RETAIN preserves valid same-owner bytes unless an explicit persistent load intentionally replaces them. The existing64-sector interface can carry data; no parallel RAM bus is needed.
3. Bind context and import completion before releasing guest. If asynchronous work is possible, an ephemeral transaction label matches completion and rejects stale responses; do not serialize it as portable identity. A command/action field and ready acknowledgment are the minimum new on-wire semantics; a “new download” pulse alone adds nothing the core does not already know.
4. Host state selection must guarantee that a presented slot belongs to the current authoritative context, or explicitly report mismatch/unresolved before core mutation. This can be host-side metadata bound to the state file. If the host cannot provide this guarantee, portable owner-key metadata and validation must be specified; a volatile generation cannot substitute for it.

The extension should be feature-negotiated/opt-in through core configuration/capability. Other cores retain existing behavior. Old hosts with no capability cannot claim strict F06 ownership: either explicit legacy replay behavior or fail closed for that guarantee; never silently treat absent action as validated RETAIN. Standalone builds need a local explicit policy/initializer or the same external context interface. No production command number, identity width, format number, key encoding or register implementation is allocated in this investigation.

This is the minimum **semantic** API change. Choosing exact wire encoding requires a focused API design/compatibility step; inventing a small fixed “exact ID” now would conceal an unproven uniqueness assumption.

## 29. Minimal solution

For exact SRAM replay with known correct ROM/state: full32 KiB using current DMA, existing mapper controls and current wrong-ROM guard; no new identity hardware. For the **strict retained ownership requirement**, add the small host-authoritative RETAIN/INITIALIZE/ready/state-association contract in28, then use the same full capture. Do not add a sticky access bit, large SRAM shadow bank, new CRC engine or general SRAM database.

The new information is a trustworthy lifecycle decision and completed initialization, not an observed-access heuristic. The host already handles paths and bytes, so this belongs at the boundary rather than a timing-sensitive runtime guess. Current source does not supply the required assertion.

## 30. Exactness classification

|Architecture|Classification|Assumption/limit|
|---|---|---|
|Complete SRAM snapshot, same ROM/config and correct state supplied|EXACT UNDER EXISTING MISTER CONTRACT for replay|No claim of fresh-cartridge isolation or universal wrong-ROM rejection|
|Per-basename host selection as unconditional content identity|INSUFFICIENT|Source proves directory/extension aliases; no file-content validation|
|ROM-start/mount/completion as universal owner|INSUFFICIENT|No load for missing/empty/readonly saves|
|Generation-only|INSUFFICIENT|Not portable; does not change bytes|
|Size/checksum or access-derived capability|HEURISTIC|Strong structured collisions/no future-access proof|
|CRC32+size owner comparison|PRACTICALLY UNIQUE BUT NOT MATHEMATICALLY EXACT|Needs explicit initialization and normalization policy|
|Authoritative host context, defined initialization, correct slot association|Exact under the **new explicitly defined** context contract|Not an existing guarantee; no fingerprint authentication claim|

The last row is deliberately not mislabeled “EXACT UNDER EXISTING MISTER CONTRACT.” Its required contract is new. No current candidate establishes mathematical equality of arbitrary ROM files from a short finite fingerprint.

## 31. Decision gate

**E. SMALL FRAMEWORK EXTENSION IS REQUIRED.** Existing host naming does not guarantee ROM-content identity; existing lifecycle does not establish SRAM ownership for no-file games; local finite fingerprints remain practical approximations and cannot restore missing history. The mandatory Phase12 conditional is true but its stronger premise is not an unconditional guarantee in the inspected implementation.

This preserves the distinction from the previous F06 investigation rather than assuming all old conclusions remain true: host-side association is now traced and verified, and it is sufficient for ordinary same-game replay. It is **not sufficient for the additional strict ownership contract**. A scope change explicitly accepting replay-only behavior would remove the need for the extension, but this investigation does not manufacture such authorization.

## 32. F06 implementation architecture — recommendation only

Because E is selected, **do not implement F06 yet**. First settle the minimal opt-in context contract28 and host identity relation. Then:

* At load, retain valid same-owner RAM or initialize the full potentially readable array before guest/SS release; complete/deterministically define associated file import first.
* At SAVE, capture all32 KiB for ordinary Sega-reachable RAM even if disabled, bank0 active or never accessed. Snapshot mapping separately. No access-derived capability gate.
* At LOAD, validate state/context/completeness before mutation; hold persistence/guest; restore mapper and full physical SRAM through existing DMA; apply other state and existing restart; release only when coherent.
* Make the state self-contained: subsequent file/RAM changes cannot replace omitted bytes. Preserve explicit user persistent LOAD as an intentionally ordered replacement, not an automatic post-SS import.
* Define the Sega SS-restore dirty-persistence hook, absent currently, so restored state can be intentionally saved to the right file. Keep EEPROM/SC/System E ownership/layout routes distinct.

If a replay-only F06 scope is later authorized, omit new context machinery and implement only the complete-data/presence path while retaining existing media preconditions. This is an alternative scope description, not a second selected decision.

## 33. Future format requirements

Required SRAM payload: **32768 bytes =4096 DDR64 words**, physical bank0 thenbank1, independent of visibility/selection. Current ordinary-SMS range d01..1d00 already fits the payload inside96 KiB. Compared with current transfer, added data0/16384/32768 bytes depending on the old flag path. System E's overlapping VRAM layout must not be overwritten; other shared-array owners remain explicitly routed.

Existing mapper word00f already carries nvram_e/ex/p/cme and related mapper state; no new visibility/bank bits needed. Add an explicit complete-Sega-SRAM presence/kind/length rule, for example one aligned8-byte descriptor with reserved validation. A future tag/presence scheme is necessary so v17 unwritten bytes are never interpreted as complete data. No format number/address is assigned now.

Under guaranteed host state association, **0 new portable ownership bits,0 new fingerprint bits,0 serialized generation bits** are needed inside the opaque FPGA image. If strict association is implemented using host-side metadata, its key belongs to that API/file metadata contract. If validation must instead occur in FPGA, owner-key width/encoding and aligned payload are unresolved until that identity relation is defined; a guessed32/128-bit field cannot be called exact. The current32-bit gameID guard remains. Pre-F06 states are lossy and must never claim exact recovery of absent SRAM; retain established legacy footprints unless a separately specified import/rejection policy is approved.

## 34. Exact implementation test matrix

|Axis/case|Required assertion/oracle|
|---|---|
|Disabled FFFC00 after writes to both halves|Full32768 captured; perturb, LOAD, enable each bank; exact bytes/future|
|Bank0 active / nominal16 KiB transfer condition|Retained bank1 also restored; do not infer physical size from current visibility|
|Bank1 active FFFC0c|Both halves preserved; existing v17 positive case retained|
|32 KiB/extension FFFC18|All addresses including0000/3fff/4000/7fff; address-derived/random patterns and extension route|
|Before first SRAM access|Capture immediately after resolved context/import; no sram_seen gating; unknown capability full array|
|After access then disable|Same complete data as before hiding; independent control restoration|
|Soft/hard/core reset|Retained bytes versus reset mapping contract; FPGA reconfiguration separatelyFF-init|
|Same-ROM reload, no file|Authoritative RETAIN preserves both halves; immediate SAVE exact|
|Same-ROM reload, existing writable file|Explicit import order defined; file replacement intentionally wins before SAVE|
|A→B, missing/empty file|INITIALIZE fullB array before first enable/SAVE; noA byte leak|
|Readonly/short/partial/error file|Deterministic fill and valid completion; test sector and host readahead boundaries; no stale tail|
|A SAVE→B→A LOAD|Both halves return to savedA despite changed currentA file; mapping and first read exact|
|No-SRAM/UNKNOWN-capability ROM|No false capability assertion; full unknown backing captured without affecting excluded modes|
|State names aliased by directory/extension or replaced ROM|Context mismatch rejected/resolved by host contract before guest mutation; existing gameID checks retained|
|Reboot/another instance/return after otherROM|Portable same-media association works; generation counter does not reject valid state|
|Repeated LOAD|Same immutable image across3+ strong perturbations restores identical full array/future|
|SAVE-only|Guest-visible state unchanged except authorized coherent capture progress; no SRAM mutation|
|Transport stalls/duration|Ready/fixed/LFSR busy/read delays; exact-once4096 words, no data/address loss; identical suffix|
|Pending persistence/queued manual request|SS waits existing transaction; no concurrent portB mutation; later explicit import order tested|
|Late/canceled old context|Stale initialization/data/completion cannot be accepted for a new cartridge|
|Malformed/missing completeness or context|Reject before SRAM/mapper writes; no unwritten old tail consumed|
|Modes/regression/capacity|EEPROM, SC, Dahjee/CME, Evolution, System E unchanged routes; legacy/public imports, current CPU/VDP/audio/memory tests; controlled Quartus gate|

Retain the prior full98304-byte non-injective pair as a mandatory negative pre-fix/positive post-fix regression. New complete images must distinguish differing retained SRAM; follow identical future enables/reads. Exact data tests should cover every byte, not just representative first-byte probes. API and new-format tests are a plan, not claimed completed here.

## 35. Remaining uncertainties and verification limits

The user's deployed host version is unknown. Host source is pinned and byte-verified; no running MiSTer, live filesystem, HPS bus capture or hardware test was available. The two source-bound executable model families are [contracts.js](contracts.js) / [contracts.json](contracts.json) and the real production-decoder component [interface.log](interface.log). Models verify naming aliasing, source anchors, missing/empty/readonly predicates, partial-read buffer semantics, the conditionalA→B→A full-data argument and generation insufficiency. They are **not a compiled complete C++ host** or an F06 prototype. The hypothetical full capture in the model is data sufficiency reasoning, not RTL implementation.

The first attempt to compile all hps_io on ModelSim10.5b encountered existing forward declarations (including video/port-width constants). Final proof extracts the unchanged FIO block and its narrow wiring, excluding unrelated video/PS2/SD logic; no production logic or valid-byte behavior is rewritten. Mount semantics are source-traced/model-tested, not claimed covered by that FIO simulation. An unavailable WSL compiler probe was not counted as evidence. Network source retrieval used the public pinned commit; all eight snapshots match Git blob hashes. No inference depends on branch names or a moving master after capture.

No exact on-wire API/key policy was designed beyond minimum semantic requirements; no new format version, fingerprint hardware, initializer, owner latch or host change exists. The previous SRAM regression/collision logs are retained evidence, not silently reported as rerun. Stronger cryptography and resource optimization were not investigated. G08.FM remains untouched.

Reproduce the completed checks from repository root:

```powershell
node tests/savestate_f06_cartridge_identity/prepare.js
node tests/savestate_f06_cartridge_identity/contracts.js
Set-Location tests/savestate_f06_cartridge_identity
& C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/vsim.exe -c -do 'do interface.do' -l interface.log
Set-Location ../..
node tests/savestate_f06_cartridge_identity/verify.js
```

The retained host snapshots make these checks reproducible without fetching a moving version. `prepare.js` never overwrites an existing baseline manifest. Final verification requires PASS markers and zero simulator errors, not shell status alone.

## 36. Recommended next step

Authorize a **focused opt-in host/core context API design**: define authoritative cartridge identity/same-owner semantics, RETAIN versus INITIALIZE, no-file/read-only/short-file initialization, completion ordering, and portable slot association. Keep the comparison on the host if exactness is required; do not spend FPGA area on a stronger hash by default. Review compatibility with the deployed host version before implementation. F06 implementation remains separate and unauthorized here.

If the project explicitly chooses only the existing same-media replay contract, authorize the smaller full32 KiB/presence F06 fix instead and document that fresh-cartridge stale-RAM isolation is a separate lifecycle change. This conditional scope option is stated openly rather than disguised as an existing host guarantee.

## 37. git diff --stat

```text
(empty)
```

Production RTL, framework files, v17 and all tracked files unchanged. All added source snapshots, fixtures, models and reports are isolated under this investigation directory. Nothing staged. No Quartus artifacts created.

## 38. git status --short

```text
?? tests/
```

HEAD unchanged. No F06 implementation, framework change, G08.FM work, commit, push or PR.
