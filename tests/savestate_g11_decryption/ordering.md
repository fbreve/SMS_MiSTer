# Reconstruction bounds to check against actual restart traces

These are conservative source-derived bounds, not a substitute for the real
T80/SDRAM SAVE/LOAD runs. An edge means a rising clk_sys edge; a value updated
on an edge is available only after that edge's nonblocking/VHDL updates.

MC8123 has a synchronous key-address stage followed by registered decrypt d.
After logical A and opcode selection become stable, two subsequent rising
edges suffice to replace the key-selected output, provided raw data is also
stable by the second edge. Once the key stage is settled, the next rising
edge replaces d after a raw-byte change. There is no previous-byte feedback.

Sega2 has a phase-zero address capture, synchronous table-output registers,
and a phase-one output register. Because simultaneous table reads observe the
old madr, the first phase-one edge after a new phase-zero capture can still
see old table outputs. A second phase-one edge is needed. Allowing either
initial phase, five rising edges after a stable logical address/opcode input
suffice to replace madr, both table outputs and the registered result. Once
the tables have settled, two rising edges suffice after a raw-byte change.
The output calculation uses *current* raw rdt, not a latched previous word.

Thus a trace must establish both conditions at every consuming T2:

1. Address/opcode selection has had the necessary capture/table edges.
2. The correct G12 raw return has had the necessary registered-result edge.

Clocks spent frozen before DIRSet do not count toward reconstruction of a
different restored address. Similarly, address settling before a new private
T1 cannot substitute for checking its newly returned raw byte. The paused
suppressed-historical-T2 path must be measured independently from the running
historical-T2 path.

The accepted SAVE rule is real M1/MREQ, ISet00, CPU enable and the allowed
vertical-blank window, with storage idle. Requests can arrive at other decrypt
phases but those phases are not independently accepted merely because the
host requested a save. Boundary exclusions require the actual acceptance
trace/rule, not an assumption that the decrypt output was already consumed.

For complete-image collisions, distinct omitted register values by themselves
do not prove a defect. Their corresponding CPU-consumed streams and complete
architectural/memory suffix must differ after identical future inputs. If the
omitted values converge first, the trace must identify the overwrite edges.

## Worst-case setup at a legal consuming edge

Take T1 as edge0, with its new logical address/opcode/read strobe available
after the edge. The current G12 controller accepts that read at the following
q0 slot and captures its owned physical response six clocks later. Thus the
new raw byte is installed by edge7. Once logical A/opcode has settled, the
Sega table stages need at most five edges, so they are already ready before
that late raw return. Its next phase-one result edge is at most edge9.
MC's key stage is ready within two edges and its new raw result by edge8.

| Path | New raw installed by | New result installed by | Earliest ordinary T2 |
|---|---:|---:|---:|
| MC8123 | 7 | 8 | 10 |
| Sega2, either phase | 7 | 9 | 10 |

Native /10 is the shortest admitted execution interval; native /15 and private
historical /15 provide more time. Paused suppressed-T2 replay finishes T1,
then performs the phase-set/ready handoff before the next native enable. It
does not introduce a shorter consuming interval. The concrete paused trace
in causal_evidence.md has raw installed at2678207, result visible before
2678210, and consuming T2 at2678212. Holding host Pause postpones observation
and leaves the same address/raw inputs available for repeated recomputation.

These bounds explain why arbitrary old result/madr/table values cannot reach
the legal consumer and why opposite phase bits can persist without changing
guest behavior. They rely on the current G12 reference/reissue contract, not
on a long transport delay or a lucky equal plaintext byte. Registered BIOS
read stages have the weaker one-edge requirement and no independent feedback;
the final IO/Game Genie selections add no clocked result stage.
