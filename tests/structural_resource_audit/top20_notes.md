# Top 20: structural interpretation

Numbers and exact paths are in [top20.md](top20.md); full synthesis/fitted metrics and report line numbers are in [hierarchy.json](hierarchy.json). The ranking uses exclusive placed ALMs. ALUT is the combinational logic metric. Memory columns in the numeric table are subtree totals: for example the controller's one M10K belongs to its OPLL scratch child, not the9,600-bit FF sprite rings.

|Rank|Consumer|Memory, expensive selection and warnings|
|---|---|---|
|1|Savestate controller|FF rings and partial-write snapshots;8:1/9:1×4,736 recognized input selection, shared64-bit output/DDR decode. One child256×32 M10K, no direct fabric RAM. Broad ARM/header/restore fanout. No report diagnostic proves an unintended failed RAM inference.|
|2|Scaler|Line/coeff/palette/delay RAM43 M10Ks;4,059 own FF include tapped pixel/arithmetic pipelines. Coordinate/mode/burst/memory arbitration muxes;23 DSPs in subtree. Explicit logic attributes on short tapped arrays. No module-specific inference-failure warning established.|
|3|Primary sprite evaluator|64-slot enable/X/plane caches, variable count/plane updates, priority/collision reduction; no M10K. Per-slot shifters are separate children excluded from own numbers. High data-address/control loads and many physical duplicate records.|
|4|Secondary sprite evaluator|Same independent architecture for System E; cannot be removed because inactive in SMS mode. Separate live state/restore ownership and children.|
|5|Board top sys_top|Own framework controls, output selects, format/clock/reset routing; children excluded. No direct memory allocation. Effective PLL connectivity/ignored I/O assignment warnings are board/framework limitations; not a snapshot inference diagnosis.|
|6|Host hps_io|Host command/joystick/ioctl/config response selection. Small logic FIFOs and config string lookup should be distinguished from bulk memories. Partial signal/register synthesis warnings and disabled features are not evidence of a large missing block RAM.|
|7|Core top emu|Clock enables, mode/host controls, shared DDR and WRAM/NVRAM ownership muxes; large memory and peripheral children excluded. Relevant fanout through mode/enable/restore networks. Core PLL generated warnings belong to child implementation.|
|8|T80 CPU u0|Instruction/control decode and state-selection logic. Separate multiport128-bit register child; no M10K in subtree. CPU restore/microarchitecture invariants prevent arbitrary latency changes. No major failed-RAM diagnostic established.|
|9|HDMI OSD|One logical4096×8 buffer mapped to4 M10Ks;display width/count/overlay data selectors and pipeline. Selected global setup endpoint dsp_width[19]. Buffer is not fabric RAM.|
|10|HDMI PLL adjustment|Counter/arithmetic/control selection;551.3 own ALMs/503 FF, no memory. Timing/clock-management functionality, pre-existing. No direct savestate bank.|
|11|Cheat GAMEGENIE|32×34 FF with all-entry associative comparisons and last-match priority;no M10K. Full synchronous clear and concurrent reads, not ordinary RAM port structure.|
|12|VGA OSD|Separate4096×8/4-M10K output buffer and overlay/control;no accidental duplication of the HDMI pipeline established. Different output timing/lifetimes.|
|13|PLL reconfiguration IP core|288 declared counter-cache bits plus generated config/state muxes;255 fitted FF, no M10K. Existing unused dps_start_assert/incomplete-case warnings. These do not establish that vendor-generated reset/config storage should infer RAM.|
|14|Secondary CRAM|32×12 live FF,32:1×12 read mux,parallel384-bit snapshot;366.8 ALMs/404 FF. RAM inference blocker is observable full-bank read, not an inferred-memory warning.|
|15|Primary CRAM|Same independent palette;364.3 ALMs/399 FF. Runtime same-clock/read-write collision contract requires proof before changing ports.|
|16|System wrapper|Mapper/ROM/decryption/CPU/VDP/audio data selection and gates;31 own FF;children excluded. Core setup traverses mapper-to-CPU cone, not necessarily wrapper-only logic. Existing unused psg_div2 warning is not a large resource charge.|
|17|OPLL envelope generator|Arithmetic/control and local state-response mux;236 own FF. Child18×25 envelope memory uses1 M10K. No broad parallel OPLL snapshot. Pipeline/algorithm arithmetic need not be RAM-like.|
|18|Host video_calc|Timing measurement counters, accumulation, response/selection;649 own FF/no RAM. Counter banks hold simultaneous observations, not an ordinary addressed buffer.|
|19|Guest IO|Port/bus/peripheral decode, small protocol registers and restore selection;187 own FF, no memory. GG/private protocol children and structural aliasing require lifetime-aware accounting.|
|20|ALSA|Host audio FIFO/result/address/control pipeline,550 own FF/no M10K in fitted subtree. Burst/channel/sample selection;no evidence that all registers form one inferred-RAM candidate. Framework stream/CDC constraints apply.|

The complete map/fit warning/message tables were inspected along with the retained normalized baseline warning comparison. No new warnings were generated by this audit. “No inference-failure diagnostic established” means the reports do not justify inventing a module-specific warning; the explicit port/reset/source structures, not a warning count, support the memory findings. Top-level warning categories are retained in the main report and original result ledger.
