# Controlled resource and timing disposition

**PASS — READY TO COMMIT.** This is the paired seed1 build with the F06
settings, device, toolchain and BUILD_DATE261025. All137 input hashes were
checked; only the four authorized core source files differ. Map, fit,
assembler and TimeQuest succeeded. No framework/QSF/SDC optimization occurred.

|Metric|F06 v18|G08.FM v19|Delta|
|---|---:|---:|---:|
|ALMs needed|37,131|37,117|-14|
|ALMs placed|38,450|38,599|+149|
|Fitted registers|48,899|48,880|-19|
|Synthesis registers|46,290|46,327|+37|
|M10K|488|488|0|
|Memory bits|3,818,050|3,818,050|0|
|DSP blocks|39|39|0|
|Fitted logic ALUTs|46,728|46,835|+107|
|Route-through ALUTs|18,203|18,266|+63|
|Worst setup|+0.366 ns|+0.104 ns|-0.262 ns|
|Worst hold|+0.234 ns|+0.239 ns|+0.005 ns|
|Violating timing summaries|0|0|0|

Placed usage is92.100%, an increase of0.356 percentage points. Remaining
placed capacity is3,311 ALMs. The needed/placed distinction matters:
recoverable packing estimates rise1,964→2,055 and unavailable estimates
fall645→573. Thus38,599−2,055+573=37,117. The lower needed estimate and fitted
register count are fitter outcomes, not a resource optimization by this task.

[Synthesis hierarchy evidence](synthesis_delta.json) accounts for all37 added
synthesis registers: controller+17 (sample16 plus presence), AudioMix+4 and
downstream audio_out+16. The latter20 correspond exactly to ten former
low-bit[1,2] merges. Restoring a full signed16-bit value prevents those merges.
The respective synthesis ALUT deltas are+69/+13/+99. No extra OPLL state bank,
DSP, memory bits or M10K was added. No compression/optimization pass was run.

The global setup bottleneck changes within the unchanged HDMI domain:

- F06: `ascal|o_vacpt[5]` → `ascal|o_vpixq_pre[2].r[3]`, +0.366 ns.
- v19: shadowmask shift-tap RAM output → `hdmi_osd|dsp_width[19]`, +0.104 ns
  (also tied on bits13/12). Relationship6.732 ns, data delay5.753 ns,
  clock skew−0.675 ns.

The endpoints differ, so subtracting their delays is not an isolated causal
measurement of the FM correction. The source identity check establishes no
HDMI RTL change. The result is consistent with placement/routing perturbation;
it does not establish a new FM critical path. Setup margin is reduced and
remains positive; it must remain visible in the later global timing audit.
See [setup paths](early_paths_setup.rpt).

The emulation domain passes at+0.895 ns versus+0.983 ns. Its selected worst
path moves from `ce_cpu` → `sdram|q[0]` to
`mapper_detect|rom_crc32[17]` → `T80|IR[3]`. Both are unchanged logic outside
the new sample-cache path. [Core paths](early_emu_setup.rpt) record the
endpoints. Worst hold moves from VDP2 shifter31 `shift0[6]→[7]` to VDP1
shifter60 `shift0[2]→[3]`, improving to+0.239 ns. See
[hold paths](early_paths_hold.rpt).

Routing completed successfully: estimated average interconnect40%, peak66%
in regionX45_Y23..X55_Y34. There are no final routing failures. No new warning
types or normalized messages appeared. The same38 retained critical-warning
messages and existing unconstrained setup/hold categories remain; this result
does not claim a newly fully constrained design. Detailed normalized
comparisons are in [early_results.json](early_results.json).

No confirmation build was run: the first paired build passes all timing,
routing and memory gates; the modest placement delta is accounted for, with
no unexplained new bank or critical FM path. A favorable-seed search was not
performed. Global ALM/timing optimization and hardware validation remain
separate recommended roadmap tasks.

The first supplemental emulation-path query lacked the per-process Z: drive
mapping and did not open the project. Its log is retained under `pilots/`;
the successful query recreated and checked the same workspace mapping. This
was a read-only STA query, not another compile/fit or confirmation build.
