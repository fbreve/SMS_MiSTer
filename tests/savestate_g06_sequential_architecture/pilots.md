# Excluded setup and scheduling pilots

These are not production findings or completed proof counts.

- Initial branch creation hit the filesystem sandbox's Git ref-write restriction. The explicitly requested branch was then created through the authorized escalation; no production change resulted.
- The first ModelSim command used the repository root rather than this directory and could not open its macro. Its logs were moved here as compile_path_pilot*.log.
- VHDL signal-procedure actuals indexed by a process-loop variable were rejected as nonstatic. Local fixed-slice merge functions replaced those procedure calls before runtime testing. Original hardware state and mapping were unchanged.
- An initial local test sampled its expected concatenation in the same simulator delta as updating the backing expected vector. Row0 was therefore supplied with old zero data. The fixture now lets that combinational oracle settle before writing; the full state/output comparison remains strict. No candidate mapping change resolved that pilot.
- The first integrated-fixture preparer looked for the controller instance in vdp_tb.sv; this family keeps it in header.svh. Preparation stopped before a usable run. A separate forward-declaration compile issue was corrected by declaring sprite_word/owner before new transport wires.
- The first complete-image protocol run had an undriven restart_out mock. The binary-image assertion rejected it. The mock is now explicitly ordinary-context zero; no saved word was scrubbed or assertion relaxed.
- An unconditional high-BUSY protocol pilot starved the existing required32-consecutive-idle-clock freeze drain. It was interrupted and retained as protocol/candidate/starvation_pilot.log. The completed transaction-qualified profiles use the established fixture rule and permit idle drain. No production liveness defect is claimed.
- A dense read-response scheduling pilot was stopped to avoid redundant interpreted function work. The completed miter still compares every clock, explicitly exercises every address, randomizes reads and guest inputs, and covers all16 configurations. Only the completed terminal count is used.

No baseline guest oracle, input ROM, first resumed clock, pixel position, status flag or comparison tolerance was changed to turn a replay failure into a pass.
